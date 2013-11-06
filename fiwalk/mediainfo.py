#!/usr/bin/env python

import subprocess
import sys

from lxml import etree

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

def main(data):
    original_xml = subprocess.check_output(['mediainfo', '-f', '--Output=XML', data])
    xml = etree.fromstring(original_xml)

    if not is_recognized(xml):
        print 'mediainfo_recognized: false'
        return

    print 'mediainfo_recognized: true'
    print 'mediainfo_xml: {}'.format(original_xml.replace('\n', ''))
    tracks = xml.findall('.//track')

    stream_types = ['video', 'audio', 'other', 'image',
        'text', 'attachment', 'chapter']

    for stream_type in stream_types:
        print enumerate_tracks(stream_type, tracks)

if __name__ == '__main__':
    data = sys.argv[1]
    main(data)
