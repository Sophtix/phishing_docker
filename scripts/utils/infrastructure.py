import argparse
import json
import subprocess
from pathlib import Path
import sys
import requests
import urllib3

urllib3.disable_warnings()


def config_smtp(domain: str, sender: str) -> str:
    """
    Configures SMTP for a domain, create a mailbox for the phishing sender
    :param domain: Domain to configure
    :param sender: Phishing sender
    :return: DKIM key
    """
    print(f"Configuring SMTP for {domain}")
    mailcow_config = config['mailcow']
    base_url = mailcow_config['url']
    session = requests.Session()
    session.verify = False
    session.headers.update({"X-API-Key": f"{mailcow_config['apikey']}"})

    # Add domain
    add_domain = {
        "active": "1",
        "domain": domain,
        "restart_sogo": "10"
    }
    res = session.post(f"{base_url}/add/domain", json=add_domain)
    data = res.json()
    if res.status_code != 200 and data['type'] == "error":
        print(f"Error adding domain: {data['msg']}")
        exit(1)

    # Add mailbox
    add_mailbox = {
        "active": "1",
        "domain": domain,
        "local_part": sender,
        "name": sender,
        "password": mailcow_config['mailbox_passowrd'],
        "password2": mailcow_config['mailbox_passowrd']
    }
    res = session.post(f"{base_url}/add/mailbox", json=add_mailbox)
    data = res.json()
    if res.status_code != 200 and data['type'] == "error":
        print(f"Error adding mailbox: {data['msg']}")
        exit(1)

    res = session.get(f"{base_url}/get/dkim/{domain}")
    data = res.json()
    if res.status_code != 200 and data['type'] == "error":
        print(f"Error getting DKIM: {data['msg']}")
        exit(1)
    return data['dkim_txt']


def generate_dns_records(domain: str, dkim: str) -> list[dict[str, str]]:
    machine_ip = config['ip']
    records_data: dict[str, list[dict[str, str]]] = config['dns']
    dns_records = []
    for record_type, records in records_data.items():
        for record in records:
            data = {
                "type": record_type.upper(),
                "name": record['name'].replace("{{domain}}", domain),
                "data": record['content'].replace("{{domain}}", domain).replace("{{ip}}", machine_ip).replace(
                    "{{dkim}}", dkim),
                "ttl": 600,
            }
            if record_type == "MX":
                data['priority'] = record['priority']

            dns_records.append(data)
    return dns_records


def config_godaddy(domain: str, dkim: str):
    print(f"Configuring GoDaddy for {domain}")
    godaddy_config = config['godaddy']
    base_url = godaddy_config['url']
    session = requests.Session()
    session.headers.update({"Authorization": f"sso-key {godaddy_config['apikey']}:{godaddy_config['secret']}", "Content-Type": "application/json", "Accept": "application/json"})

    # Set DNS records
    dns_records = generate_dns_records(domain, dkim)
    nameservers = [{"type": "NS", "data": ns, "name": "@", "ttl": 600} for ns in godaddy_config['nameservers']]
    dns_records.extend(nameservers)

    res = session.put(f"{base_url}/v1/domains/{domain}/records", json=dns_records)
    if res.status_code != 200:
        data = res.json()
        print(f"Error modifying DNS records: {data['message']}")
        exit(1)


def config_cloudflare(domain: str, dkim: str):
    print(f"Configuring Cloudflare for {domain}")
    godaddy_config = config['godaddy']
    base_url = godaddy_config['url']
    session = requests.Session()
    session.headers.update({"Authorization": f"sso-key {godaddy_config['apikey']}:{godaddy_config['secret']}"})

    # Replace NS records in godaddy
    ns_records = [{"data": ns, "name": "@", "ttl": 600} for ns in config['cloudflare']['nameservers']]
    res = session.put(f"{base_url}/v2/domains/{domain}/records/NS", json=ns_records)
    res.raise_for_status()

    # Create a new Cloudflare zone
    cloudflare_config = config['cloudflare']
    base_url = cloudflare_config['url']
    session = requests.Session()
    session.headers.update(
        {"X-Auth-Email": f"Bearer {cloudflare_config['email']}", "X-Auth-Key": cloudflare_config['apikey']})
    data = {
        "name": domain,
        "jump_start": False,
        "account": {"id": cloudflare_config['account_id']},
        "type": "full"
    }
    res = session.post(f"{base_url}", json=data)
    res.raise_for_status()

    zone_id = res.json()['result']['id']

    # Set DNS records
    dns_records = generate_dns_records(domain, dkim)
    res = session.put(f"{base_url}/{zone_id}/dns_records", json=dns_records)
    res.raise_for_status()


def main(domain, sender, provider):
    dkim = config_smtp(domain, sender)
    if not dkim:
        print("Failed to configure SMTP")
        exit(1)
    match provider:
        case "godaddy":
            config_godaddy(domain, dkim)
        case "cloudflare":
            config_cloudflare(domain, dkim)
    # config_nginx(domain)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Configure phishing infrastructure")
    parser.add_argument("-p", "--provider", choices=["godaddy", "cloudflare"], help="DNS provider to configure", required=True)
    parser.add_argument("-d", "--domain", help="Domain to add", required=True)
    parser.add_argument("-s", "--sender", help="Phishing sender", required=True)
    args = parser.parse_args()

    config_path = Path(__file__).parent / "config.json"
    with open(config_path) as f:
        config = json.load(f)

    main(args.domain, args.sender, args.provider)
