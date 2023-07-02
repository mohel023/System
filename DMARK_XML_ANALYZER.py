import xml.etree.ElementTree as ET


def analyze_dmarc_report(xml_file):
    tree = ET.parse(xml_file)
    root = tree.getroot()

    records = []
    for record in root.findall(".//feedback/record"):
        source_ip = record.find("row/source_ip").text
        count = int(record.find("row/count").text)
        disposition = record.find("row/policy_evaluated/disposition").text

        records.append({
            "source_ip": source_ip,
            "count": count,
            "disposition": disposition
        })

    return records


# Example usage
report_file = "dmarc_report.xml"
results = analyze_dmarc_report(report_file)

for result in results:
    print("Source IP:", result["source_ip"])
    print("Count:", result["count"])
    print("Disposition:", result["disposition"])
    print("------------------------")
