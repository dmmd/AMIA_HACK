#!/usr/bin/env python

import json
import os.path
import subprocess
import sys

from lxml import etree

MAPPING_FILE = "mapping.json"

def is_recognized(xml):
    track = xml.find('.//track')
    if track is not None:
        if track.find('./Format') is not None:
            return True
        else:
            return False
    else:
        return False

def enumerate_tracks(stream_type, tracks):
    results = filter(lambda t: t.get('type') == stream_type.capitalize(), tracks)
    return 'mediainfo_general_num_{}_stream: {}'.format(stream_type, len(results))

def load_mapping():
    mapping_file = os.path.join(os.path.dirname(__file__), MAPPING_FILE)
    with open(mapping_file) as mapping:
        return json.load(mapping)

def map_streams(xml, mapping):
    results = []

    for stream_type in mapping.keys():
        el = xml.find(".//track[@type='{}']".format(stream_type))
        if el is not None:
            results.extend(map_stream(el, mapping.get(stream_type)))

    return results

def map_stream(xml, mapping):
    if mapping is None:
        return []

    results = []
    for mediainfo_tag, output_tag in mapping.iteritems():
        try:
            value = xml.find('./{}'.format(mediainfo_tag)).text
            if value:
                results.append('{}: {}'.format(output_tag, value))
        except:
            continue

    return results

def main(data):
    original_xml = subprocess.check_output(['mediainfo', '-f', '--Output=XML', data])
    xml = etree.fromstring(original_xml)

    if not is_recognized(xml):
        print 'mediainfo_recognized: false'
        return

    print 'mediainfo_recognized: true'
    tracks = xml.findall('.//track')

    stream_types = ['video', 'audio', 'other', 'image',
        'text', 'attachment', 'chapter']

    for stream_type in stream_types:
        print enumerate_tracks(stream_type, tracks)

    mapping = load_mapping()
    values = map_streams(xml, mapping)

    for item in values:
        print item

if __name__ == '__main__':
    data = sys.argv[1]
    main(data)
