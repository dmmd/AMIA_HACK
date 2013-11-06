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
    original_xml = subprocess.check_output(['mediainfo', '-f', '--Output=XML', data])
    xml = etree.fromstring(original_xml)

    if not is_recognized(xml):
        print 'mediainfo_recognized: false'
        return

    print 'mediainfo_recognized: true'
    print 'mediainfo_xml: {}'.format(original_xml.replace('\n', ''))
    tracks = xml.findall('.//track')

    audio_tracks = filter(lambda t: t.get('type') == 'Audio', tracks)
    print 'mediainfo_tracks_audio: {}'.format(len(audio_tracks))

    video_tracks = filter(lambda t: t.get('type') == 'Video', tracks)
    print 'mediainfo_tracks_video: {}'.format(len(video_tracks))

    image_tracks = filter(lambda t: t.get('type') == 'Video', tracks)
    print 'mediainfo_tracks_image: {}'.format(len(image_tracks))

if __name__ == '__main__':
    data = sys.argv[1]
    main(data)
