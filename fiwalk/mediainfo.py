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

def main(data):
    print 'mediainfo_filename: {}'.format(data)

    original_xml = subprocess.check_output(['mediainfo', '-f', '--Output=XML', data])
    xml = etree.fromstring(original_xml)

    if not is_recognized(xml):
        print 'mediainfo_recognized: false'
        return

    print 'mediainfo_recognized: true'
    print 'mediainfo_xml: {}'.format(original_xml.replace('\n', ''))
    tracks = xml.findall('.//track')
    audio_tracks = filter(lambda t: t.get('type') == 'Audio', tracks)
    print 'tracks_audio: {}'.format(len(audio_tracks))

if __name__ == '__main__':
    data = sys.argv[1]
    main(data)
