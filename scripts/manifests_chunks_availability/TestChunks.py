
import random
import re
import os
import time
import xml.etree.ElementTree as ET
from contextlib import ExitStack

import urllib3
from datetime import datetime, timedelta
from utils import DecodeToSeconds, get_vssp_time_string, get_time_string
TEMP_FOLDER = "./"

def create_packaging_profile(packaging_profile_name, packaging_abbreviation, manifest_file_name, manifest_string):
    return {
        "packaging_profile_name" : packaging_profile_name,
        "packaging_abbreviation" : packaging_abbreviation,
        "manifest_file_name"     : manifest_file_name,
        "manifest_string"        : manifest_string
    }

def try_parse_int(value):
    try:
        return int(value), True
    except ValueError:
        return value, False


def create_test_settings(packaging_profile, pod_list=None, asset_id = None, device_profile = None, download_media=False, max_chunks_to_write=-1, verbose=False,  next_asset_on_error=False):
    settings = packaging_profile.copy()
    settings["pod_list"] = pod_list
    settings["asset_id"] = asset_id
    if device_profile:
        settings["device_profile"] = device_profile
    else:
        settings["device_profile"] = settings["packaging_profile_name"]
    settings["download_media"] = download_media
    settings["max_chunks_to_write"] = max_chunks_to_write
    settings["verbose"] = verbose
    settings["next_asset_on_error"] = next_asset_on_error
    return settings


def create_chunk_container_smooth():
    chunk_container = {
        "time_stamp_list" : [],
        "quality_level_list" : [],
        "media" : ""
    }
    return chunk_container

def create_chunk_container_dash():
    chunk_container = {
        "time_stamp_list" : ["Init"],
        "quality_level_list" : [],
        "media" : ""
    }
    return chunk_container

def extract_chunk_info_dash(root):
    chunk_info_list = []
    content_type = root.attrib['type']

    if content_type == 'static':
        duration_in_seconds = float(DecodeToSeconds(root.attrib['mediaPresentationDuration']))
    else:
        duration_in_seconds = float(DecodeToSeconds(root.attrib['timeShiftBufferDepth']))

    for unode in root:
        print(unode)
        if unode.tag == "Period":
            for node in unode:
                # if node.attrib['contentType'] == "video" and (node.attrib['group'] == "1" or node.attrib['group'] == "2"): # video or audio
                # if node.attrib['group'] == "1" or node.attrib['group'] == "2": # video or audio
                if True:
                    chunk_info = create_chunk_container_dash()
                    chunk_info["contentType"] = node.attrib['contentType']                    
                    chunk_info["attrib"] = node.attrib.copy()
                    chunk_info["duration_in_seconds"] = duration_in_seconds
                    for child in node:
                        if child.tag == "Representation":
                            chunk_info["quality_level_list"].append(child.attrib['bandwidth'])
                        if child.tag == "SegmentTemplate":                            
                            timescale = int(child.attrib['timescale'])
                            chunk_info["timescale"] = timescale
                            chunk_info["media"] = (child.attrib['media'].replace("$Bandwidth$", "{bitrate}")).replace("$Time$", "{start time}")
                            for segment in child:
                                if segment.tag == "SegmentTimeline":                                    
                                    get_media_segments(segment.findall("S"), chunk_info)
                    chunk_info_list.append(chunk_info)
    return chunk_info_list

def get_media_segments(chunks, chunk_info):
    duration_in_seconds = chunk_info["duration_in_seconds"]
    time_stamp_list = chunk_info["time_stamp_list"]
    timescale = chunk_info["timescale"]
    last_interval = 0
    first_time = True
    for chunk in chunks:
        if 't' in chunk.attrib:
            last_interval = int(chunk.attrib['t'])
            time_stamp_list.append(str(last_interval))

        if first_time:
            first_timestamp = last_interval
            last_timestamp = int(duration_in_seconds + (first_timestamp / timescale)) * timescale
            chunk_info["last_timestamp"] = last_timestamp 
            first_time = False

        # print(chunk.attrib)
        if 'd' in chunk.attrib:
            interval = chunk.attrib['d']
            last_interval += int(interval)
            time_stamp_list.append(str(last_interval))
        

        if 'r' in chunk.attrib:
            n_repeats = chunk.attrib['r']
            for _ in range(0, int(n_repeats)):
                last_interval += int(interval)
                if last_interval <= last_timestamp: 
                    time_stamp_list.append(str(last_interval))
        else:
            n_repeats = 0

def extract_chunk_info_smooth(root):
    chunk_info_list = []
    duration_in_seconds = int(root.attrib['Duration']) / 10e6
    for unode in root:
        # print(unode)
        if unode.tag == "StreamIndex":
            chunk_info = create_chunk_container_smooth()
            chunk_info["contentType"] = unode.attrib['Type']
            chunk_info["attrib"] = unode.attrib.copy()
            chunk_info["duration_in_seconds"] = duration_in_seconds
            chunk_info["timescale"] = 10e6
            chunk_info["media"] = unode.attrib['Url']

            get_media_segments(unode.findall("c"), chunk_info)
            for node in unode:
                if node.tag == "QualityLevel":
                    chunk_info["quality_level_list"].append(node.attrib['Bitrate'])
        chunk_info_list.append(chunk_info)
    return chunk_info_list

def test_asset_chunks(f, test_settings, asset_id):
    start_time = time.clock()
    print("******************************")
    test_settings["asset_id"] = asset_id
    print(test_settings["asset_id"])
    # print(test_settings["pod_list"])
    pod_list = test_settings["pod_list"]
    test_settings["pod"] = random.choice(pod_list)

    common_url_prefix = "http://{pod}/{packaging_abbreviation}/{asset_id}/{manifest_file_name}"

    url = (common_url_prefix+"{manifest_string}?device={device_profile}").format_map(test_settings)
    print("url: '{}'".format(url))
    save_request_list = True
    if save_request_list:
        with open("request_list.txt", "a+") as req_file:
            req_file.writelines([url])
            req_file.write("\n")

    response = http.request('GET', url=url, headers={"Cache-Control":"no-cache"}).data.decode()
    print("{} for '{}'".format(response, url))
    # return 


    try:
        response = re.sub(' xmlns="[^"]+"', '', response, count=1)
        # if test_settings["packaging_profile_name"] == "SMOOTH":
        #     with open(os.path.join(TEMP_FOLDER,'SmoothManifest.ism'), 'r') as myfile:
        #         response = myfile.read().replace('\n', '')
        root = ET.fromstring(response)
    except Exception as e:
        print(e)
        print("{} for '{}'".format(response, url))
        return False
    next_asset_on_error = test_settings["next_asset_on_error"]
    packaging_profile_name = test_settings["packaging_profile_name"]
    chunk_info_list = extract_chunk_info(packaging_profile_name, root)
    for chunk_info in chunk_info_list:
        last_timestamp = chunk_info["last_timestamp"]
        test_settings["media"] = chunk_info["media"]
        url_original = (common_url_prefix+"/{media}").format_map(test_settings)
        cfg = {
                "quality_level_list": chunk_info["quality_level_list"], 
                "time_stamp_list": chunk_info["time_stamp_list"], 
                "url_original": url_original
                }
        verbose = test_settings["verbose"]
        max_chunks_to_write = test_settings["max_chunks_to_write"]
        download_media = test_settings["download_media"]
        for quality_level in cfg["quality_level_list"]:
            asset_cache_hits = 0
            asset_requests = 0
            # print("Quality level: {}".format(quality_level))

            attribs = chunk_info["attrib"]

            with ExitStack() as cm:
                if download_media:
                    file_name = os.path.join(TEMP_FOLDER, get_media_file_name(asset_id, quality_level, attribs))
                    output_file = cm.enter_context(open(file_name, "wb+"))
                written_chunks = 0
                for time_stamp in cfg["time_stamp_list"]:
                    url = url_original.format_map({
                        "bitrate" : quality_level,
                        "start time" : time_stamp
                        })

                    if download_media:
                        response = http.request('GET', url)
                        output_file.write(response.data)
                        output_file.flush()
                    else:
                        response = http.request('HEAD', url)

                    written_chunks += 1
                    val, success = try_parse_int(time_stamp)
                    if success and last_timestamp <= val:
                        break

                    if (max_chunks_to_write != -1) and ((max_chunks_to_write or 1000000) < written_chunks):
                        break

                    response_status = response.status
                    
                 
                    test_settings["total_failed"] += 1
                    xcache_str = response.headers["X-Cache"]
                    test_settings["total_requests"] += 1
                    asset_requests +=1
                    if len(re.findall('MISS', xcache_str)) < 2:
                        # print("Cache hit!!!!!")
                        test_settings["cache_hits"] += 1
                        asset_cache_hits += 1

                    if response_status != 200 or verbose:
                        report_str_2 = "URL: {} | Res: {} | Hits: {} | Requests: {} ".format(url, response_status, asset_cache_hits, asset_requests)
                        print(report_str_2)
                        if response_status != 200 and next_asset_on_error:
                            break

                    report_str = "'{}'|{}|{}|{}".format(url, response_status, asset_cache_hits, asset_requests)
                    f.write(report_str)
                    f.write('\n')
        f.flush()
    end_time = time.clock()
    log_str = "{} - Cache hits: {}. Time: {} seconds".format(asset_id, test_settings["cache_hits"], end_time - start_time)
    print(log_str)

def get_media_file_name(asset_id, quality_level, attribs):
    return "id_{}-ql_{}-gr_{}.{}".format(asset_id, quality_level, attribs["group"], EXTENSION_MAP[attribs["contentType"]])




def extract_chunk_info(packaging_profile_name, root):
    if packaging_profile_name == "SMOOTH":
        media = extract_chunk_info_smooth(root)
    elif packaging_profile_name == "DASH":
        media = extract_chunk_info_dash(root)
    else:
        pass
    return media


def test_all_streams_for_asset(test_settings, asset_id_list):
    test_settings["total_failed"] = 0
    test_settings["cache_hits"] = 0    
    test_settings["total_requests"] = 0
    with open(os.path.join(TEMP_FOLDER, 'VSPP_chunk_test_{}.csv'.format(get_time_string())), 'w') as f:
        report_str = "URL|Res|CacheHits|Requests\n"
        f.write(report_str)
        size = len(asset_id_list)
        print("Total assets:", size)
        for idx, asset_id in enumerate(asset_id_list):
      
            test_asset_chunks(f, test_settings, asset_id)

            log_str = "Done with {} out of {}".format(idx + 1, size)
            print(log_str)

http = urllib3.PoolManager(50)

def get_asset_id_list_from_file():
    with open("asset.txt") as f:
        return f.read().splitlines() 


PACKAGING_PROFILE_SMOOTH = create_packaging_profile("SMOOTH", "shss", "index.ism", "/Manifest")
PACKAGING_PROFILE_HLS    = create_packaging_profile("HLS", "shls", "index.m3u8", "")
PACKAGING_PROFILE_DASH   = create_packaging_profile("DASH", "sdash", "index.mpd", "/Manifest")


EXTENSION_MAP = {
    "video":"mp4",
    "audio":"m4a",
    "subtitle":"3gp"
}

CONTENT_TYPES = ["vod", "replay", "review", "dvrrb", "dvras"]
COUNTRIES = ["nl", "be", "ss", "ukv"]
ENVIRONMENTS = ["labe2esi", "prod", "labziggoe2e"]



def generate_sample_from_list(list_to_sample, sample_size):
    random.shuffle(list_to_sample)
    list_to_sample = asset_id_list_from_file[:min(sample_size, len(list_to_sample))]
    return list_to_sample


def create_pod_set(pod_info : dict):
    pod = pod_info["pod"]
    num_web_objects = pod_info["num_web_objects"]
    return [pod.format(i) for i in range(1,num_web_objects+1)] 
curr_time = datetime.now() + timedelta(days=4)
time_range_start = get_vssp_time_string(curr_time)
time_range_end = get_vssp_time_string(curr_time + timedelta(minutes=10))
pod_MT_lab_vod =       create_pod_set({"pod" : "wp{}.pod1.vod.labe2esi.nl.dmdsdp.com",      "num_web_objects" : 28, "suffix" :  ""})
pod_VFZ_prod_vod =     create_pod_set({"pod" : "wp{}.pod1.vod.prod.nl.dmdsdp.com",          "num_web_objects" : 1,  "suffix" :  "&start={}&end={}".format(time_range_start, time_range_end)})
pod_VFZ_prod_rb =      create_pod_set({"pod" : "wp{}.pod1.dvrrb.prod.nl.dmdsdp.com",        "num_web_objects" : 1,  "suffix" :  "&start={}&end={}".format(time_range_start, time_range_end)})
pod_be_prod_vod =      create_pod_set({"pod" : "wp{}.pod1.vod.prod.be.dmdsdp.com",          "num_web_objects" : 28, "suffix" :  "/<VOD_ID>/index.mpd/Manifest?device=HEVC-STB"})
pod_ch_prod_vod =      create_pod_set({"pod" : "wp{}.pod1.vod.prod.ch.dmdsdp.com",          "num_web_objects" : 28, "suffix" :  "/<VOD_ID>/index.mpd/Manifest?device=HEVC-STB"})
pod_e2esi_lab_rb =     create_pod_set({"pod" : "wp{}.pod1.dvrrb.labe2esi.nl.dmdsdp.com",    "num_web_objects" : 28, "suffix" :  "/LIVE$Nederland_1_HD/index.mpd/Manifest?device=HEVC-STB&start=2017-11-07T10:00:41Z&end=2017-11-07T12:22:41Z"})
pod_e2esi_lab_replay = create_pod_set({"pod" : "wp{}.pod1.replay.labe2esi.nl.dmdsdp.com",   "num_web_objects" : 28, "suffix" :  "/LIVE$Nederland_1_HD/index.mpd/Manifest?device=HEVC-STB&start=2017-11-07T10:00:41Z&end=2017-11-07T12:22:41Z"})
pod_e2esi_lab_vod =    create_pod_set({"pod" : "wp{}.pod1.vod.labe2esi.nl.dmdsdp.com",      "num_web_objects" : 28, "suffix" :  "/<VOD_ID>/index.mpd/Manifest?device=HEVC-STB"})
pod_uk_prod_vod =      create_pod_set({"pod" : "wp{}.pod1.vod.prod.ukv.dmdsdp.com",         "num_web_objects" : 28, "suffix" :  "/LIVE$Nederland_1_HD/index.mpd/Manifest?device=HEVC-STB&start=2017-11-07T10:00:41Z&end=2017-11-07T12:22:41Z"})
pod_vfz_lab_rb =       create_pod_set({"pod" : "wp{}.pod1.dvrrb.labziggoe2e.nl.dmdsdp.com", "num_web_objects" : 1,  "suffix" :  "/LIVE$Nederland_1_HD/index.mpd/Manifest?device=HEVC-STB&start=2017-11-07T10:00:41Z&end=2017-11-07T12:22:41Z"})




def main():
    # test_settings  = create_test_settings(PACKAGING_PROFILE_SMOOTH, device_profile = "Test-PR-HSS")
    # test_settings = create_test_settings(PACKAGING_PROFILE_SMOOTH, download_media=True, max_chunks_to_write=100)
    # test_settings   = create_test_settings(PACKAGING_PROFILE_DASH, download_media=False, verbose=False) 
    # test_settings = create_test_settings(PACKAGING_PROFILE_DASH, download_media=True, max_chunks_to_write=100, verbose=True) 
    # test_settings = create_test_settings(PACKAGING_PROFILE_DASH, device_profile="EOS-DASH-HEVC", download_media=True, max_chunks_to_write=100, verbose=True) 
    # test_settings = create_test_settings(PACKAGING_PROFILE_DASH, pod_list=pod_uk_prod_vod, device_profile="DASH", download_media=True, max_chunks_to_write=100, verbose=True) 
    test_settings = create_test_settings(PACKAGING_PROFILE_SMOOTH, pod_list=pod_uk_prod_vod, device_profile="Orion-HSS", download_media=False, max_chunks_to_write=None, verbose=True, next_asset_on_error=False) 

    # test_settings = create_test_settings(settings_dash, None, None, "HEVC-STB", download_media = False) # Only one working
    # test_settings = create_test_settings(settings_smooth, None, None, "Orion-HSS")

    asset_id_list = get_asset_id_list_from_file()
    
    # asset_id_list = ['8ecbb8166198aeb5dc3f0340d11e243d_12e962fa6e610fcf2cdcd357e068b767']
    # asset_id_list = ['073a27e4982235cd8d99a6a8e9a56cf3_e0131f4ac6333cfb9a930b96ac6cd239']
    # asset_id_list = ['00bf5fd1bdf4e2a8fdf0b1f48d728446_3EA8773D77D96D6D3ECFE80BF71891B0']
   
    # asset_id_list = generate_sample_from_list(asset_id_list, 10)
    test_all_streams_for_asset(test_settings, asset_id_list)



if __name__ == "__main__":
    main()
    

# http://{manager_address:port}/rolling_buffer/{channel}/{start}/{end}/{device_profile}[/{user_id}][/{nonce}][/{uac_id}][/{signature}]

# http://wp1.pod1.dvrrb.labe2esi.nl.dmdsdp.com/rolling_buffer/0059/LIVE/END/DASH
# http://{manager_address:port}/rolling_buffer/{channel}/{start}/{end}/{device_profile}[/{user_id}][/{nonce}][/{uac_id}][/{signature}]

# http://wp1.pod1.dvrrb.labe2esi.nl.dmdsdp.com/sdash/LIVE$0059/index.mpd/Manifest?start=2017-10-10T08:00:00Z&end=2017-10-105T12:00:00Z&device=DASH
