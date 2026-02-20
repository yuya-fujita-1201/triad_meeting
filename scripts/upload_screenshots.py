#!/usr/bin/env python3
"""Upload screenshots to App Store Connect via API.

Usage:
    python3 scripts/upload_screenshots.py --device ipad-13 --dir app/screenshots/ipad-13
    python3 scripts/upload_screenshots.py --device iphone-6.7 --dir app/screenshots/iphone-6.7
    python3 scripts/upload_screenshots.py  # defaults: ipad-13, app/screenshots/ipad-13
"""

import jwt
import time
import requests
import hashlib
import os
import json
import sys
import argparse

# App Store Connect API credentials
API_KEY_ID = "P26V6QTLTW"
ISSUER_ID = "e359cd97-a6d4-4ef9-bcb3-24336fda0e74"

# Resolve paths relative to project root
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
PROJECT_ROOT = os.path.dirname(SCRIPT_DIR)
P8_KEY_PATH = os.path.join(PROJECT_ROOT, ".appstoreconnect/private_keys/AuthKey_P26V6QTLTW.p8")

# App info
APP_ID = "6758553766"

# Device type mapping
DEVICE_TYPES = {
    "iphone-5.5": "APP_IPHONE_55",
    "iphone-6.5": "APP_IPHONE_65",
    "iphone-6.7": "APP_IPHONE_67",
    "iphone-6.9": "APP_IPHONE_69",
    "ipad-13": "APP_IPAD_PRO_3GEN_129",
    "ipad-11": "APP_IPAD_PRO_3GEN_11",
}

# Parse arguments
parser = argparse.ArgumentParser(description="Upload screenshots to App Store Connect")
parser.add_argument("--device", default="ipad-13", choices=DEVICE_TYPES.keys(),
                    help="Device type (default: ipad-13)")
parser.add_argument("--dir", default=None,
                    help="Screenshot directory (default: app/screenshots/{device})")
args = parser.parse_args()

DISPLAY_TYPE = DEVICE_TYPES[args.device]
SCREENSHOT_DIR = args.dir or os.path.join(PROJECT_ROOT, f"app/screenshots/{args.device}")
if not os.path.isabs(SCREENSHOT_DIR):
    SCREENSHOT_DIR = os.path.join(PROJECT_ROOT, SCREENSHOT_DIR)
SCREENSHOT_FILES = sorted([f for f in os.listdir(SCREENSHOT_DIR) if f.endswith('.png')])

def generate_token():
    """Generate JWT token for App Store Connect API"""
    with open(P8_KEY_PATH, 'r') as f:
        private_key = f.read()

    now = int(time.time())
    payload = {
        "iss": ISSUER_ID,
        "iat": now,
        "exp": now + 1200,  # 20 minutes
        "aud": "appstoreconnect-v1"
    }
    headers = {
        "alg": "ES256",
        "kid": API_KEY_ID,
        "typ": "JWT"
    }

    token = jwt.encode(payload, private_key, algorithm="ES256", headers=headers)
    return token

def api_request(method, url, token, json_data=None, **kwargs):
    """Make API request to App Store Connect"""
    headers = {
        "Authorization": f"Bearer {token}",
        "Content-Type": "application/json"
    }
    resp = requests.request(method, url, headers=headers, json=json_data, **kwargs)
    return resp

def get_app_store_version(token):
    """Get the current app store version (inflight)"""
    url = f"https://api.appstoreconnect.apple.com/v1/apps/{APP_ID}/appStoreVersions"
    params = {"filter[appStoreState]": "PREPARE_FOR_SUBMISSION"}
    resp = api_request("GET", url, token, params=params)
    data = resp.json()
    if resp.status_code != 200:
        print(f"Error getting versions: {resp.status_code}")
        print(json.dumps(data, indent=2))
        # Try without filter
        resp = api_request("GET", f"https://api.appstoreconnect.apple.com/v1/apps/{APP_ID}/appStoreVersions", token)
        data = resp.json()
        print(f"\nAll versions:")
        for v in data.get("data", []):
            print(f"  {v['id']}: state={v['attributes']['appStoreState']}, version={v['attributes']['versionString']}")
        return None

    versions = data.get("data", [])
    if versions:
        v = versions[0]
        print(f"Found version: {v['id']} (state: {v['attributes']['appStoreState']}, version: {v['attributes']['versionString']})")
        return v["id"]
    return None

def get_localizations(token, version_id):
    """Get app store version localizations"""
    url = f"https://api.appstoreconnect.apple.com/v1/appStoreVersions/{version_id}/appStoreVersionLocalizations"
    resp = api_request("GET", url, token)
    data = resp.json()
    localizations = data.get("data", [])
    for loc in localizations:
        print(f"  Localization: {loc['id']} (locale: {loc['attributes']['locale']})")
    return localizations

def get_screenshot_sets(token, localization_id):
    """Get existing screenshot sets for a localization"""
    url = f"https://api.appstoreconnect.apple.com/v1/appStoreVersionLocalizations/{localization_id}/appScreenshotSets"
    resp = api_request("GET", url, token)
    data = resp.json()
    sets = data.get("data", [])
    for s in sets:
        print(f"  Screenshot set: {s['id']} (type: {s['attributes']['screenshotDisplayType']})")
    return sets

def create_screenshot_set(token, localization_id, display_type):
    """Create a new screenshot set"""
    url = "https://api.appstoreconnect.apple.com/v1/appScreenshotSets"
    payload = {
        "data": {
            "type": "appScreenshotSets",
            "attributes": {
                "screenshotDisplayType": display_type
            },
            "relationships": {
                "appStoreVersionLocalization": {
                    "data": {
                        "type": "appStoreVersionLocalizations",
                        "id": localization_id
                    }
                }
            }
        }
    }
    resp = api_request("POST", url, token, json_data=payload)
    data = resp.json()
    if resp.status_code in (200, 201):
        set_id = data["data"]["id"]
        print(f"  Created screenshot set: {set_id}")
        return set_id
    else:
        print(f"  Error creating screenshot set: {resp.status_code}")
        print(json.dumps(data, indent=2))
        return None

def reserve_screenshot(token, screenshot_set_id, filename, filesize):
    """Reserve a screenshot upload slot"""
    url = "https://api.appstoreconnect.apple.com/v1/appScreenshots"

    # Calculate MD5 checksum
    filepath = os.path.join(SCREENSHOT_DIR, filename)
    md5 = hashlib.md5(open(filepath, 'rb').read()).hexdigest()

    payload = {
        "data": {
            "type": "appScreenshots",
            "attributes": {
                "fileName": filename,
                "fileSize": filesize
            },
            "relationships": {
                "appScreenshotSet": {
                    "data": {
                        "type": "appScreenshotSets",
                        "id": screenshot_set_id
                    }
                }
            }
        }
    }
    resp = api_request("POST", url, token, json_data=payload)
    data = resp.json()
    if resp.status_code in (200, 201):
        screenshot_id = data["data"]["id"]
        upload_ops = data["data"]["attributes"].get("uploadOperations", [])
        print(f"    Reserved screenshot: {screenshot_id} ({len(upload_ops)} upload operations)")
        return screenshot_id, upload_ops
    else:
        print(f"    Error reserving screenshot: {resp.status_code}")
        print(json.dumps(data, indent=2))
        return None, None

def upload_screenshot_parts(filepath, upload_operations):
    """Upload screenshot file parts"""
    with open(filepath, 'rb') as f:
        file_data = f.read()

    for i, op in enumerate(upload_operations):
        url = op["url"]
        offset = op["offset"]
        length = op["length"]
        method = op["method"]
        request_headers = {h["name"]: h["value"] for h in op["requestHeaders"]}

        chunk = file_data[offset:offset + length]

        resp = requests.request(method, url, headers=request_headers, data=chunk)
        if resp.status_code in (200, 201):
            print(f"    Part {i+1}/{len(upload_operations)} uploaded OK")
        else:
            print(f"    Part {i+1} FAILED: {resp.status_code} {resp.text[:200]}")
            return False
    return True

def commit_screenshot(token, screenshot_id, filepath):
    """Commit the uploaded screenshot"""
    md5 = hashlib.md5(open(filepath, 'rb').read()).hexdigest()

    url = f"https://api.appstoreconnect.apple.com/v1/appScreenshots/{screenshot_id}"
    payload = {
        "data": {
            "type": "appScreenshots",
            "id": screenshot_id,
            "attributes": {
                "sourceFileChecksum": md5,
                "uploaded": True
            }
        }
    }
    resp = api_request("PATCH", url, token, json_data=payload)
    if resp.status_code == 200:
        print(f"    Screenshot committed successfully")
        return True
    else:
        print(f"    Error committing: {resp.status_code}")
        print(json.dumps(resp.json(), indent=2))
        return False

def main():
    print("=== App Store Connect iPad Screenshot Upload ===\n")

    # Generate token
    print("1. Generating JWT token...")
    token = generate_token()
    print("   Token generated OK\n")

    # Get app store version
    print("2. Getting app store version...")
    version_id = get_app_store_version(token)
    if not version_id:
        print("   ERROR: No version found")
        sys.exit(1)

    # Get localizations
    print("\n3. Getting localizations...")
    localizations = get_localizations(token, version_id)
    if not localizations:
        print("   ERROR: No localizations found")
        sys.exit(1)

    # Use Japanese localization (or first available)
    ja_loc = None
    for loc in localizations:
        if loc["attributes"]["locale"] == "ja":
            ja_loc = loc
            break
    if not ja_loc:
        ja_loc = localizations[0]

    loc_id = ja_loc["id"]
    print(f"   Using localization: {ja_loc['attributes']['locale']} ({loc_id})\n")

    # Get existing screenshot sets
    print("4. Getting existing screenshot sets...")
    existing_sets = get_screenshot_sets(token, loc_id)

    # Find or create screenshot set for the specified device type
    target_display_type = DISPLAY_TYPE
    target_set_id = None

    for s in existing_sets:
        if s["attributes"]["screenshotDisplayType"] == target_display_type:
            target_set_id = s["id"]
            print(f"   Found existing set for {args.device}: {target_set_id}")
            break

    if not target_set_id:
        print(f"\n5. Creating screenshot set for {args.device} ({target_display_type})...")
        target_set_id = create_screenshot_set(token, loc_id, target_display_type)
        if not target_set_id:
            print("   ERROR: Could not create screenshot set")
            sys.exit(1)

    # Upload each screenshot
    print(f"\n6. Uploading {len(SCREENSHOT_FILES)} screenshots...")
    for i, filename in enumerate(SCREENSHOT_FILES):
        filepath = os.path.join(SCREENSHOT_DIR, filename)
        filesize = os.path.getsize(filepath)
        print(f"\n  [{i+1}/{len(SCREENSHOT_FILES)}] {filename} ({filesize} bytes)")

        # Reserve
        screenshot_id, upload_ops = reserve_screenshot(token, target_set_id, filename, filesize)
        if not screenshot_id:
            print(f"    SKIPPING {filename}")
            continue

        # Upload parts
        success = upload_screenshot_parts(filepath, upload_ops)
        if not success:
            print(f"    UPLOAD FAILED for {filename}")
            continue

        # Commit
        commit_screenshot(token, screenshot_id, filepath)

    print("\n=== Done! ===")

if __name__ == "__main__":
    main()
