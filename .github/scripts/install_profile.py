"""Installs the Gallery's App Store provisioning profile, making whatever is missing first.

Fetched through the App Store Connect API rather than left to -allowProvisioningUpdates: a
manual-signing export only reads profiles installed in ~/Library/MobileDevice, it doesn't fetch
them (the same lesson the apps' workflows learned). The first run on a fresh account has
nothing to fetch, so the bundle id is registered and the profile created here, against the
distribution certificate the job imported (matched by serial number, CERT_SERIAL).

Environment: API_KEY_ID, API_ISSUER_ID, CERT_SERIAL, BUNDLE_ID, PROFILE_NAME.
"""
import base64
import os
import time

import jwt
import requests

API = "https://api.appstoreconnect.apple.com/v1"

key_id = os.environ["API_KEY_ID"]
issuer_id = os.environ["API_ISSUER_ID"]
cert_serial = os.environ["CERT_SERIAL"].upper().lstrip("0")
bundle_id = os.environ["BUNDLE_ID"]
profile_name = os.environ["PROFILE_NAME"]

with open(os.path.expanduser(f"~/.appstoreconnect/private_keys/AuthKey_{key_id}.p8")) as f:
    private_key = f.read()

token = jwt.encode(
    {"iss": issuer_id, "exp": int(time.time()) + 600, "aud": "appstoreconnect-v1"},
    private_key,
    algorithm="ES256",
    headers={"kid": key_id},
)
headers = {"Authorization": f"Bearer {token}"}


def call(method, path, **kwargs):
    resp = requests.request(method, f"{API}{path}", headers=headers, timeout=30, **kwargs)
    if not resp.ok:
        # Apple says why in the body (an agreement to accept, a key without the role, …).
        raise SystemExit(f"App Store Connect API {method} {path} {resp.status_code}: {resp.text}")
    return resp.json()


def install(attrs):
    profiles_dir = os.path.expanduser("~/Library/MobileDevice/Provisioning Profiles")
    os.makedirs(profiles_dir, exist_ok=True)
    dest = os.path.join(profiles_dir, f"{attrs['uuid']}.mobileprovision")
    with open(dest, "wb") as f:
        f.write(base64.b64decode(attrs["profileContent"]))
    print(f"Installed {profile_name!r} ({attrs['uuid']}) -> {dest}")


existing = call("GET", "/profiles", params={"filter[name]": profile_name, "filter[profileState]": "ACTIVE"})["data"]
if existing:
    install(existing[0]["attributes"])
    raise SystemExit(0)

bundles = call("GET", "/bundleIds", params={"filter[identifier]": bundle_id})["data"]
bundle = next((b for b in bundles if b["attributes"]["identifier"] == bundle_id), None)
if bundle is None:
    bundle = call("POST", "/bundleIds", json={"data": {"type": "bundleIds", "attributes": {
        "identifier": bundle_id, "name": "Vitral Gallery", "platform": "IOS",
    }}})["data"]
    print(f"Registered bundle id {bundle_id}")

certificates = call("GET", "/certificates", params={"filter[certificateType]": "DISTRIBUTION,IOS_DISTRIBUTION", "limit": 200})["data"]
certificate = next(
    (c for c in certificates if c["attributes"]["serialNumber"].upper().lstrip("0") == cert_serial),
    None,
)
if certificate is None:
    raise SystemExit(f"No distribution certificate with serial {cert_serial} on the account")

created = call("POST", "/profiles", json={"data": {
    "type": "profiles",
    "attributes": {"name": profile_name, "profileType": "IOS_APP_STORE"},
    "relationships": {
        "bundleId": {"data": {"type": "bundleIds", "id": bundle["id"]}},
        "certificates": {"data": [{"type": "certificates", "id": certificate["id"]}]},
    },
}})["data"]
print(f"Created {profile_name!r}")
install(created["attributes"])
