--
-- PostgreSQL database dump
--

\restrict 51kHp25pDHLUUTf5tkmTciiODhAKYnuQ21mWipIZVhOT2twjj7zeeqz1wOe5z0D

-- Dumped from database version 16.11 (Ubuntu 16.11-0ubuntu0.24.04.1)
-- Dumped by pg_dump version 16.11 (Ubuntu 16.11-0ubuntu0.24.04.1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: vector; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS vector WITH SCHEMA public;


--
-- Name: EXTENSION vector; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION vector IS 'vector data type and ivfflat and hnsw access methods';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: embeddings; Type: TABLE; Schema: public; Owner: nr
--

CREATE TABLE public.embeddings (
    id integer NOT NULL,
    source_id integer NOT NULL,
    vector public.vector(1024)
);


ALTER TABLE public.embeddings OWNER TO nr;

--
-- Name: embeddings_id_seq; Type: SEQUENCE; Schema: public; Owner: nr
--

CREATE SEQUENCE public.embeddings_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.embeddings_id_seq OWNER TO nr;

--
-- Name: embeddings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nr
--

ALTER SEQUENCE public.embeddings_id_seq OWNED BY public.embeddings.id;


--
-- Name: research_topic_sections; Type: TABLE; Schema: public; Owner: nr
--

CREATE TABLE public.research_topic_sections (
    research_topic_id integer NOT NULL,
    section_id integer NOT NULL
);


ALTER TABLE public.research_topic_sections OWNER TO nr;

--
-- Name: research_topic_tags; Type: TABLE; Schema: public; Owner: nr
--

CREATE TABLE public.research_topic_tags (
    research_topic_id integer NOT NULL,
    tag_id integer NOT NULL
);


ALTER TABLE public.research_topic_tags OWNER TO nr;

--
-- Name: research_topics; Type: TABLE; Schema: public; Owner: nr
--

CREATE TABLE public.research_topics (
    id integer NOT NULL,
    name text NOT NULL,
    description text
);


ALTER TABLE public.research_topics OWNER TO nr;

--
-- Name: research_topics_id_seq; Type: SEQUENCE; Schema: public; Owner: nr
--

CREATE SEQUENCE public.research_topics_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.research_topics_id_seq OWNER TO nr;

--
-- Name: research_topics_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nr
--

ALTER SEQUENCE public.research_topics_id_seq OWNED BY public.research_topics.id;


--
-- Name: section_tags; Type: TABLE; Schema: public; Owner: nr
--

CREATE TABLE public.section_tags (
    section_id integer NOT NULL,
    tag_id integer NOT NULL
);


ALTER TABLE public.section_tags OWNER TO nr;

--
-- Name: source_documents; Type: TABLE; Schema: public; Owner: nr
--

CREATE TABLE public.source_documents (
    id integer NOT NULL,
    title text NOT NULL,
    author text,
    publication_date date,
    language text,
    description text,
    url text,
    download_state integer DEFAULT 0
);


ALTER TABLE public.source_documents OWNER TO nr;

--
-- Name: source_documents_id_seq; Type: SEQUENCE; Schema: public; Owner: nr
--

CREATE SEQUENCE public.source_documents_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.source_documents_id_seq OWNER TO nr;

--
-- Name: source_documents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nr
--

ALTER SEQUENCE public.source_documents_id_seq OWNED BY public.source_documents.id;


--
-- Name: source_sections; Type: TABLE; Schema: public; Owner: nr
--

CREATE TABLE public.source_sections (
    id integer NOT NULL,
    document_id integer,
    tag_id integer,
    section_title text,
    content text NOT NULL,
    section_number integer,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.source_sections OWNER TO nr;

--
-- Name: source_sections_id_seq; Type: SEQUENCE; Schema: public; Owner: nr
--

CREATE SEQUENCE public.source_sections_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.source_sections_id_seq OWNER TO nr;

--
-- Name: source_sections_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nr
--

ALTER SEQUENCE public.source_sections_id_seq OWNED BY public.source_sections.id;


--
-- Name: tag_links; Type: TABLE; Schema: public; Owner: nr
--

CREATE TABLE public.tag_links (
    source_tag_id integer NOT NULL,
    target_tag_id integer NOT NULL,
    relation_type text DEFAULT 'related'::text
);


ALTER TABLE public.tag_links OWNER TO nr;

--
-- Name: tags; Type: TABLE; Schema: public; Owner: nr
--

CREATE TABLE public.tags (
    id integer NOT NULL,
    name text NOT NULL
);


ALTER TABLE public.tags OWNER TO nr;

--
-- Name: tags_id_seq; Type: SEQUENCE; Schema: public; Owner: nr
--

CREATE SEQUENCE public.tags_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tags_id_seq OWNER TO nr;

--
-- Name: tags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nr
--

ALTER SEQUENCE public.tags_id_seq OWNED BY public.tags.id;


--
-- Name: embeddings id; Type: DEFAULT; Schema: public; Owner: nr
--

ALTER TABLE ONLY public.embeddings ALTER COLUMN id SET DEFAULT nextval('public.embeddings_id_seq'::regclass);


--
-- Name: research_topics id; Type: DEFAULT; Schema: public; Owner: nr
--

ALTER TABLE ONLY public.research_topics ALTER COLUMN id SET DEFAULT nextval('public.research_topics_id_seq'::regclass);


--
-- Name: source_documents id; Type: DEFAULT; Schema: public; Owner: nr
--

ALTER TABLE ONLY public.source_documents ALTER COLUMN id SET DEFAULT nextval('public.source_documents_id_seq'::regclass);


--
-- Name: source_sections id; Type: DEFAULT; Schema: public; Owner: nr
--

ALTER TABLE ONLY public.source_sections ALTER COLUMN id SET DEFAULT nextval('public.source_sections_id_seq'::regclass);


--
-- Name: tags id; Type: DEFAULT; Schema: public; Owner: nr
--

ALTER TABLE ONLY public.tags ALTER COLUMN id SET DEFAULT nextval('public.tags_id_seq'::regclass);


--
-- Data for Name: embeddings; Type: TABLE DATA; Schema: public; Owner: nr
--

COPY public.embeddings (id, source_id, vector) FROM stdin;
\.


--
-- Data for Name: research_topic_sections; Type: TABLE DATA; Schema: public; Owner: nr
--

COPY public.research_topic_sections (research_topic_id, section_id) FROM stdin;
15	440
15	441
15	442
15	443
15	444
15	445
15	446
15	447
15	448
15	449
15	450
15	451
15	452
15	453
15	454
15	455
15	456
15	457
15	458
15	459
15	460
15	461
15	462
15	463
15	464
15	465
15	466
15	467
15	468
15	469
15	470
15	471
15	472
15	473
15	474
15	475
15	476
15	477
15	478
15	479
15	480
15	481
15	482
15	483
15	484
15	485
15	486
15	487
15	488
15	489
15	490
15	491
15	492
15	493
15	494
15	495
15	496
15	497
15	498
15	499
15	500
15	501
15	502
15	503
15	504
15	505
15	506
15	507
15	508
15	509
15	510
15	511
15	512
15	513
15	514
15	515
15	516
15	517
15	518
15	519
15	520
15	521
15	522
15	523
15	524
15	525
15	526
15	527
15	528
15	529
15	530
15	531
15	532
15	533
15	534
15	535
15	536
15	537
15	538
15	539
15	540
15	541
15	542
15	543
15	544
15	545
15	546
15	547
15	548
15	549
15	550
15	551
15	552
15	553
15	554
15	555
15	556
15	557
15	558
15	559
15	560
15	561
15	562
15	563
15	564
15	565
15	566
15	567
16	568
16	569
16	570
16	571
16	572
16	573
16	574
16	575
16	576
16	577
16	578
16	579
16	580
16	581
16	582
16	583
16	584
16	585
16	586
16	587
16	588
16	589
16	590
16	591
16	592
16	593
16	594
16	595
16	596
16	597
16	598
16	599
16	600
16	601
16	602
16	603
16	604
16	605
16	606
\.


--
-- Data for Name: research_topic_tags; Type: TABLE DATA; Schema: public; Owner: nr
--

COPY public.research_topic_tags (research_topic_id, tag_id) FROM stdin;
\.


--
-- Data for Name: research_topics; Type: TABLE DATA; Schema: public; Owner: nr
--

COPY public.research_topics (id, name, description) FROM stdin;
15	ESP32开发与ESP-IDF框架应用	\N
16	Ruby语言开发与ERB模板引擎应用	\N
\.


--
-- Data for Name: section_tags; Type: TABLE DATA; Schema: public; Owner: nr
--

COPY public.section_tags (section_id, tag_id) FROM stdin;
\.


--
-- Data for Name: source_documents; Type: TABLE DATA; Schema: public; Owner: nr
--

COPY public.source_documents (id, title, author, publication_date, language, description, url, download_state) FROM stdin;
439	Get Started - ESP32 - — ESP-IDF Programming Guide v5.5.1 ...	\N	\N	\N	This is documentation for stable version v5.5.1 of ESP-IDF. Other ESP-IDF Versions are also available. Introduction . ESP32 is a system on a ...	https://docs.espressif.com/projects/esp-idf/en/stable/esp32/get-started/index.html	0
440	Get Started - ESP32 - — ESP-IDF Programming Guide v4.3 ...	\N	\N	\N	The scripts introduced in this step install compilation tools required by ESP-IDF inside the user home directory: $HOME/.espressif on Linux and macOS, % ...	https://docs.espressif.com/projects/esp-idf/en/v4.3/esp32/get-started/index.html	0
441	Standard Setup of Toolchain for Windows - ESP32 - — ESP-IDF ...	\N	\N	\N	Introduction · The installation path of ESP-IDF and ESP-IDF Tools must not be longer than 90 characters. · The installation path of Python or ESP-IDF must not ...	https://docs.espressif.com/projects/esp-idf/en/stable/esp32/get-started/windows-setup.html	0
442	JTAG Debugging - ESP32 - — ESP-IDF Programming Guide v5.5.1 ...	\N	\N	\N	Introduction . The ESP32 has two powerful Xtensa cores, allowing for a great deal of variety of program architectures. The FreeRTOS OS that comes with ESP-IDF ...	https://docs.espressif.com/projects/esp-idf/en/stable/esp32/api-guides/jtag-debugging/index.html	0
443	Introduction - ESP32 - — ESP-IDF Programming Guide v5.5.1 ...	\N	\N	\N	The tutorial offers a hands-on approach to understanding Bluetooth LE and working with the ESP-IDF framework for Bluetooth LE applications.	https://docs.espressif.com/projects/esp-idf/en/stable/esp32/api-guides/ble/get-started/ble-introduction.html	0
444	Standard Setup of Toolchain for Windows (CMake) — ESP-IDF ...	\N	\N	\N	Introduction¶. ESP-IDF requires some prerequisite tools to be installed so you can build firmware for the ESP32. The prerequisite tools include Git, a cross- ...	https://docs.espressif.com/projects/esp-idf/en/v3.3/get-started-cmake/windows-setup.html	0
445	Get Started - - — ESP-IDF Programming Guide v4.1 documentation	\N	\N	\N	The scripts introduced in this step install compilation tools required by ESP-IDF inside the user home directory: $HOME/.espressif on Linux and macOS, % ...	https://docs.espressif.com/projects/esp-idf/en/v4.1/get-started/index.html	0
446	Get Started - - — ESP-IDF Programming Guide release-v3.3 ...	\N	\N	\N	Other ESP-IDF Versions are also available. Introduction¶. ESP32 integrates Wi-Fi (2.4 GHz band) and Bluetooth 4.2 solutions on a single chip, along with dual ...	https://docs.espressif.com/projects/esp-idf/en/release-v3.3/get-started/index.html	0
447	Introduction - ESP32-C61 - — ESP-IDF Programming Guide v5.5.1 ...	\N	\N	\N	This document provides an architecture overview of the Bluetooth Low Energy (Bluetooth LE) stack in ESP-IDF and some quick links to related documents and ...	https://docs.espressif.com/projects/esp-idf/en/stable/esp32c61/api-guides/ble/overview.html	0
448	Standard Setup of Toolchain for Windows - ESP32 - — ESP-IDF ...	\N	\N	\N	Introduction¶. ESP-IDF requires some prerequisite tools to be installed so you can build firmware for supported chips. The prerequisite tools include Python ...	https://docs.espressif.com/projects/esp-idf/en/v4.2.1/esp32/get-started/windows-setup.html	0
449	espressif/esp-idf: Espressif IoT Development Framework ... - GitHub	\N	\N	\N	Espressif IoT Development Framework. Official development framework for Espressif SoCs. - espressif/esp-idf.	https://github.com/espressif/esp-idf	0
450	esp-idf/examples/protocols/README.md at master · espressif/esp ...	\N	\N	\N	Espressif IoT Development Framework. Official development framework for Espressif SoCs. - esp-idf/examples/protocols/README.md at master ...	https://github.com/espressif/esp-idf/blob/master/examples/protocols/README.md	0
451	esp-idf/examples/peripherals/i2c/i2c_tools/README.md at master ...	\N	\N	\N	Espressif IoT Development Framework. Official development framework for Espressif SoCs. - esp-idf/examples/peripherals/i2c/i2c_tools/README.md at master ...	https://github.com/espressif/esp-idf/blob/master/examples/peripherals/i2c/i2c_tools/README.md	0
452	espressif/vscode-esp-idf-extension: Visual Studio Code ... - GitHub	\N	\N	\N	Visual Studio Code extension for ESP-IDF projects. Contribute to espressif/vscode-esp-idf-extension development by creating an account on GitHub.	https://github.com/espressif/vscode-esp-idf-extension	0
453	idf-eclipse-plugin/README.md at master · espressif/idf-eclipse ...	\N	\N	\N	Espressif-IDE comes with the IDF Eclipse plugins, essential Eclipse CDT plugins, and other third-party plugins from the Eclipse platform to support building ESP ...	https://github.com/espressif/idf-eclipse-plugin/blob/master/README.md	0
454	esp-idf/examples/system/unit_test/README.md at master · espressif ...	\N	\N	\N	In addition to features of Unity, this example demonstrates test registration feature of ESP-IDF. This feature works when unit test functions are declared using ...	https://github.com/espressif/esp-idf/blob/master/examples/system/unit_test/README.md	0
455	esp-idf/examples/storage/sd_card/sdmmc/README.md at master ...	\N	\N	\N	Espressif IoT Development Framework. Official development framework for Espressif SoCs. - esp-idf/examples/storage/sd_card/sdmmc/README.md at master ...	https://github.com/espressif/esp-idf/blob/master/examples/storage/sd_card/sdmmc/README.md	0
456	esp-idf/examples/provisioning/README.md at master · espressif ...	\N	\N	\N	The Android and iOS provisioning applications allow the user to configure the device manually or by scanning a QR code.	https://github.com/espressif/esp-idf/blob/master/examples/provisioning/README.md	0
457	esp-idf/examples/bluetooth/esp_ble_mesh/README.md at master ...	\N	\N	\N	Espressif IoT Development Framework. Official development framework for Espressif SoCs. - esp-idf/examples/bluetooth/esp_ble_mesh/README.md at master ...	https://github.com/espressif/esp-idf/blob/master/examples/bluetooth/esp_ble_mesh/README.md	0
458	esp-idf/examples/protocols/esp_local_ctrl/README.md at master ...	\N	\N	\N	Espressif IoT Development Framework. Official development framework for Espressif SoCs. - esp-idf/examples/protocols/esp_local_ctrl/README.md at master ...	https://github.com/espressif/esp-idf/blob/master/examples/protocols/esp_local_ctrl/README.md	0
459	VScode 安装ESP-idf 卡在Installing ESP-IDF Debug Adapter python ...	\N	\N	\N	May 27, 2022 ... VScode 安装ESP-idf 卡在Installing ESP-IDF Debug Adapter python packages in xxxxx 原创. 最新推荐文章于 2024-02-04 21:30:52 发布 ... **ESP-IDF介绍** ...	https://blog.csdn.net/huiche5674/article/details/125011510	0
460	封装ESP-IDF 组件并上传到ESP 组件注册表_esp-idf components ...	\N	\N	\N	封装ESP-IDF 组件并上传到ESP 组件注册表 原创. 最新推荐文章于 2025-10-24 23:17:25 发布. 2024-10-14 ... **ESP-IDF介绍** ESP-IDF提供了构建、编译、调试和部署ESP32与ESP8266应用的框架。	https://blog.csdn.net/m0_60134435/article/details/142874146	0
461	ESP-IDF 安装过程中驱动安装失败_espidf驱动安装失败-CSDN博客	\N	\N	\N	May 22, 2025 ... **ESP-IDF介绍** ESP-IDF提供了构建、编译、调试和部署ESP32与ESP8266 ... 热门推荐 解决Arduino IDE无法安装esp32的问题2024年12月23日更新.	https://blog.csdn.net/qq_40619699/article/details/148130905	0
462	ESP-IDF使用iot-button组件实现按键检测的功能_esp32 button-CSDN ...	\N	\N	\N	ESP-IDF使用iot-button组件实现按键检测的功能 原创. 已于 2025-03-27 19:52:07 修改. 2024-05-24 10:07:11 ... **ESP-IDF介绍** ESP-IDF提供了构建、编译、调试和部署ESP32与ESP8266应用的框架。	https://blog.csdn.net/u012121390/article/details/139162419	0
463	esp-idf 安装esp_littlefs 组件_esp32 idf移植littlefs-CSDN博客	\N	\N	\N	esp-idf 安装esp_littlefs 组件 原创. 已于 2024-03-31 23:15:57 修改. 2024-03-31 22:43:27. 阅读量841 ... **ESP-IDF介绍** ESP-IDF提供了构建、编译、调试和部署 ...	https://blog.csdn.net/weixin_43550576/article/details/137211566	0
464	ESP-IDF环境安装出现问题（报错python.exe -m pip“ is not valid ...	\N	\N	\N	2024-08-06 18:05:26. 阅读量5.4k. 收藏 23. 17赞. Lethal Rhythm113. 码龄4年 ... **ESP-IDF介绍** ESP-IDF提供了构建、编译、调试和部署ESP32与ESP8266应用的框架。	https://blog.csdn.net/qq_63698716/article/details/140962477	0
465	从码云gitee获取资源搭建ESP-IDF开发环境方法_gitee esp-idf-CSDN ...	\N	\N	\N	Feb 8, 2023 ... vip_tag. 最新推荐文章于 2024-08-16 11:19:45 发布. 2023-02-08 21:05 ... **ESP-IDF介绍** ESP-IDF提供了构建、编译、调试和部署ESP32与ESP8266 ...	https://blog.csdn.net/LaoYangCSWSN/article/details/128942891	0
466	使用ESP-IDF找不到nvs_flash.h头文件_esp找不到nvs.h-CSDN博客	\N	\N	\N	Oct 25, 2021 ... 【ESP-IDF】介绍NVS. 自我介绍一下，小编13年上海交大毕业，曾经在小公司 ... 因此收集整理了一份《2024年嵌入式&物联网开发全套学习资料》，初衷 ...	https://blog.csdn.net/qq_28695769/article/details/120950899	0
467	1-1 VSCode配置ESP-IDF开发环境-CSDN博客	\N	\N	\N	2024-11-28 18:42:08. 阅读量417. 收藏 3. 4赞. _沧浪之水_. 码龄6年. 关注 ... **ESP-IDF介绍** ESP-IDF提供了构建、编译、调试和部署ESP32与ESP8266应用的框架。它.	https://blog.csdn.net/qq_45973003/article/details/144116714	0
468	解决ESP-IDF工程里面C/C++找不到路径标红的问题_${config:idf ...	\N	\N	\N	解决ESP-IDF工程里面C/C++找不到路径标红的问题 原创. 最新推荐文章于 2025-09-10 20:51:03 发布 ... **ESP-IDF介绍** ESP-IDF提供了构建、编译、调试和部署ESP32与ESP8266应用的框架。	https://blog.csdn.net/qq_61585528/article/details/139431614	0
469	espressif/esp-dsp: DSP library for ESP-IDF - GitHub	\N	\N	\N	DSP library for ESP-IDF. Contribute to espressif/esp-dsp development by creating an account on GitHub.	https://github.com/espressif/esp-dsp	0
470	Releases · espressif/esp-idf	\N	\N	\N	Espressif IoT Development Framework. Official development framework for Espressif SoCs. - Releases · espressif/esp-idf.	https://github.com/espressif/esp-idf/releases	0
471	VSCode works really well. Worth adding setup instructions in to the ...	\N	\N	\N	Jan 26, 2017 ... espressif / esp-idf Public. Notifications You must be signed in to change notification settings; Fork 8k · Star 16.7k · Code · Issues 1.4k ...	https://github.com/espressif/esp-idf/issues/303	0
472	PSRAM Cache Issue stills exist (IDFGH-31) · Issue #2892 · espressif ...	\N	\N	\N	Dec 27, 2018 ... (As a side note: We noticed this problem when we implemented the dlmalloc memory allocator in a fork of ESP-IDF. We worked around this problem ( ...	https://github.com/espressif/esp-idf/issues/2892	0
473	W6100 (IDFGH-5966) · Issue #7654 · espressif/esp-idf	\N	\N	\N	Oct 6, 2021 ... Driver for w6100 I have had big problems with the stability of w5500, getting hot and unstable, and have been focusing og then w6100 chip.	https://github.com/espressif/esp-idf/issues/7654	0
474	ESP32 - how to do that ? · Issue #410 · espressif/esp-idf	\N	\N	\N	Mar 7, 2017 ... Hello, My project was based on esp8266, the device was scanning iBeacons, to get the rssi (and calculate the distance to nearest becaon) i ...	https://github.com/espressif/esp-idf/issues/410	0
475	Request for C++17 support (IDFGH-844) · Issue #2449 · espressif ...	\N	\N	\N	Sep 20, 2018 ... espressif / esp-idf Public. Notifications You must be signed in to change notification settings; Fork 8k · Star 16.7k · Code · Issues 1.4k ...	https://github.com/espressif/esp-idf/issues/2449	0
476	espressif/esp-iot-solution: Espressif IoT Library. IoT Device ... - GitHub	\N	\N	\N	IoT Device Drivers, Documentations and Solutions. License. Apache-2.0 license · 2.4k stars 928 forks Branches Tags Activity ... ESP-IDF Programming Guide: https ...	https://github.com/espressif/esp-iot-solution	0
477	Instrumentation options (-fsanitize) & quality control (IDF-166) · Issue ...	\N	\N	\N	Feb 1, 2018 ... As long as code analysis is run on ESP-IDF I think we'll all be happy, even if that is accessible only internally at Espressif due to licensing.	https://github.com/espressif/esp-idf/issues/1574	0
478	esp-idf/LICENSE at master · espressif/esp-idf · GitHub	\N	\N	\N	Apache License 2.0. A permissive license whose main conditions require preservation of copyright and license notices. Contributors provide an express grant of ...	https://github.com/espressif/esp-idf/blob/master/LICENSE	0
479	Restarting I2S DMA in camera mode · Issue #2027 · espressif/esp-idf	\N	\N	\N	Jun 3, 2018 ... Contributor. Issue body actions. I am using ESP-IDF 3.0. My goal is to understand and document how to receive parallel incoming and clocked ...	https://github.com/espressif/esp-idf/issues/2027	0
480	I2C problems reading data ... not sending an ACK after reading data ...	\N	\N	\N	Feb 14, 2017 ... https://github.com/espressif/esp-idf/blob/master/examples ... ContributorAuthor. More actions. Wow!! Thank you Mr @negativekelvin ... if ...	https://github.com/espressif/esp-idf/issues/344	0
481	Releases · espressif/vscode-esp-idf-extension	\N	\N	\N	Dec 10, 2024 ... Visual Studio Code extension for ESP-IDF projects. Contribute to espressif/vscode-esp-idf-extension development by creating an account on ...	https://github.com/espressif/vscode-esp-idf-extension/releases	0
482	[TW#24566] LAN8720 TX issue with ethernet_example (IDFGH ...	\N	\N	\N	Jul 8, 2018 ... espressif / esp-idf Public. Notifications You must be signed in to change notification settings; Fork 8k · Star 16.8k · Code · Issues 1.3k ...	https://github.com/espressif/esp-idf/issues/2164	0
483	esp-idf/examples/bluetooth/bluedroid/ble/ble_ibeacon/main ...	\N	\N	\N	SPDX-FileCopyrightText: 2021-2024 Espressif Systems (Shanghai) CO LTD * * SPDX-License-Identifier: Unlicense OR CC0-1.0 ...	https://github.com/espressif/esp-idf/blob/master/examples/bluetooth/bluedroid/ble/ble_ibeacon/main/ibeacon_demo.c	0
484	Simple Bluetooth Example · Issue #761 · espressif/esp-idf	\N	\N	\N	Jul 2, 2017 ... The simplest example would be for you to use the gatt_server_service_table example in the idf. This will set your ESP32 up as a peripheral for your phone to ...	https://github.com/espressif/esp-idf/issues/761	0
485	Trying to incorperate my own sensor script into the BLE Mesh sensor ...	\N	\N	\N	Nov 21, 2020 ... I have IDF v4.1 installed # get_idf # cd ~/esp/esp-idf/examples/bluetooth/esp_ble_mesh/ble_mesh_sensor_model/sensor_server # idf.py build ...	https://github.com/espressif/esp-idf/issues/6144	0
486	esp-idf/examples/bluetooth/bluedroid/ble/gatt_server/tutorial ...	\N	\N	\N	... for Espressif SoCs. - esp-idf/examples/bluetooth/bluedroid/ble/gatt_server/tutorial/Gatt_Server_Example_Walkthrough.md at master · espressif/esp-idf.	https://github.com/espressif/esp-idf/blob/master/examples/bluetooth/bluedroid/ble/gatt_server/tutorial/Gatt_Server_Example_Walkthrough.md	0
487	esp-idf/examples/bluetooth/bluedroid/ble/gatt_server/main ...	\N	\N	\N	Official development framework for Espressif SoCs. - esp-idf/examples/bluetooth/bluedroid/ble/gatt_server/main/gatts_demo.c at master · espressif/esp-idf.	https://github.com/espressif/esp-idf/blob/master/examples/bluetooth/bluedroid/ble/gatt_server/main/gatts_demo.c	0
488	esp-idf/examples/bluetooth/bluedroid/classic_bt/a2dp_sink ...	\N	\N	\N	Official development framework for Espressif SoCs. - esp-idf/examples/bluetooth/bluedroid/classic_bt/a2dp_sink/README.md at master · espressif/esp-idf.	https://github.com/espressif/esp-idf/blob/master/examples/bluetooth/bluedroid/classic_bt/a2dp_sink/README.md	0
489	esp-idf/examples/bluetooth/bluedroid/classic_bt/hfp_hf/README.md ...	\N	\N	\N	Espressif IoT Development Framework. Official development framework for Espressif SoCs. - esp-idf/examples/bluetooth/bluedroid/classic_bt/hfp_hf/README.md ...	https://github.com/espressif/esp-idf/blob/master/examples/bluetooth/bluedroid/classic_bt/hfp_hf/README.md	0
490	esp-idf/examples/bluetooth/nimble/bleprph/README.md at master ...	\N	\N	\N	Espressif IoT Development Framework. Official development framework for Espressif SoCs. - esp-idf/examples/bluetooth/nimble/bleprph/README.md at master ...	https://github.com/espressif/esp-idf/blob/master/examples/bluetooth/nimble/bleprph/README.md	0
491	esp-idf/examples/bluetooth/bluedroid/ble/gatt_client/tutorial ...	\N	\N	\N	... for Espressif SoCs. - esp-idf/examples/bluetooth/bluedroid/ble/gatt_client/tutorial/Gatt_Client_Example_Walkthrough.md at master · espressif/esp-idf.	https://github.com/espressif/esp-idf/blob/master/examples/bluetooth/bluedroid/ble/gatt_client/tutorial/Gatt_Client_Example_Walkthrough.md	0
492	esp-idf/examples/wifi/getting_started/station/main ...	\N	\N	\N	Official development framework for Espressif SoCs. - esp-idf/examples/wifi/getting_started/station/main/station_example_main.c at master · espressif/esp-idf.	https://github.com/espressif/esp-idf/blob/master/examples/wifi/getting_started/station/main/station_example_main.c	0
493	esp-idf/examples/wifi/getting_started/station/README.md at master ...	\N	\N	\N	Espressif IoT Development Framework. Official development framework for Espressif SoCs. - esp-idf/examples/wifi/getting_started/station/README.md at master ...	https://github.com/espressif/esp-idf/blob/master/examples/wifi/getting_started/station/README.md	0
494	esp-idf/examples/wifi/fast_scan/main/fast_scan.c at master ...	\N	\N	\N	Espressif IoT Development Framework. Official development framework for Espressif SoCs. - esp-idf/examples/wifi/fast_scan/main/fast_scan.c at master ...	https://github.com/espressif/esp-idf/blob/master/examples/wifi/fast_scan/main/fast_scan.c	0
495	esp-idf/examples/wifi/getting_started/softAP/main ...	\N	\N	\N	Official development framework for Espressif SoCs. - esp-idf/examples/wifi/getting_started/softAP/main/softap_example_main.c at master · espressif/esp-idf.	https://github.com/espressif/esp-idf/blob/master/examples/wifi/getting_started/softAP/main/softap_example_main.c	0
496	esp-idf/examples/wifi/espnow/main/espnow_example_main.c at ...	\N	\N	\N	Espressif IoT Development Framework. Official development framework for Espressif SoCs. - esp-idf/examples/wifi/espnow/main/espnow_example_main.c at master ...	https://github.com/espressif/esp-idf/blob/master/examples/wifi/espnow/main/espnow_example_main.c	0
497	esp-idf/examples/wifi/getting_started/softAP/README.md at master ...	\N	\N	\N	Espressif IoT Development Framework. Official development framework for Espressif SoCs. - esp-idf/examples/wifi/getting_started/softAP/README.md at master ...	https://github.com/espressif/esp-idf/blob/master/examples/wifi/getting_started/softAP/README.md	0
498	esp-idf/examples/wifi/softap_sta/main/softap_sta.c at master ...	\N	\N	\N	SPDX-FileCopyrightText: 2023-2025 Espressif Systems (Shanghai) CO LTD * * SPDX-License-Identifier: Unlicense OR CC0-1.0 */ /* WiFi softAP & station Example ...	https://github.com/espressif/esp-idf/blob/master/examples/wifi/softap_sta/main/softap_sta.c	0
499	esp-idf/examples/wifi/espnow/README.md at master · espressif/esp ...	\N	\N	\N	This example shows how to use ESPNOW of wifi. Example does the following steps: This example need at least two ESP devices.	https://github.com/espressif/esp-idf/blob/master/examples/wifi/espnow/README.md	0
500	esp-idf/examples/wifi/power_save/README.md at master · espressif ...	\N	\N	\N	This example shows how to use power save mode of wifi. Power save mode only works in station mode. If the modem sleep mode is enabled, station will switch ...	https://github.com/espressif/esp-idf/blob/master/examples/wifi/power_save/README.md	0
501	Get Started - ESP32 - — ESP-IDF Programming Guide v5.2 ...	\N	\N	\N	This is documentation for stable version v5.2 of ESP-IDF. Other ESP-IDF Versions are also available. Introduction . ESP32 is a system on a ...	https://docs.espressif.com/projects/esp-idf/en/v5.2/esp32/get-started/index.html	0
502	Get Started - ESP32-C5 - — ESP-IDF Programming Guide v5.5.1 ...	\N	\N	\N	Other ESP-IDF Versions are also available. Introduction . ESP32-C5 is a system on a chip that integrates the following features: Wi-Fi 6 ( ...	https://docs.espressif.com/projects/esp-idf/en/stable/esp32c5/get-started/index.html	0
503	Get Started - ESP32 - — ESP-IDF Programming Guide v4.2 ...	\N	\N	\N	Other ESP-IDF Versions are also available. Introduction¶. ESP32 is a system on a chip that integrates the following features: Wi-Fi (2.4 GHz band).	https://docs.espressif.com/projects/esp-idf/en/v4.2/esp32/get-started/index.html	0
504	Get Started - ESP32-C3 - — ESP-IDF Programming Guide release ...	\N	\N	\N	This is documentation for branch release/v4.4 of ESP-IDF. Other ESP-IDF Versions are also available. Introduction . ESP32-C3 is ...	https://docs.espressif.com/projects/esp-idf/en/release-v4.4/esp32c3/get-started/index.html	0
505	Standard Setup of Toolchain for Windows - ESP32 - — ESP-IDF ...	\N	\N	\N	For this Getting Started we're going to use the Command Prompt, but after ESP-IDF is installed you can use Eclipse or another graphical IDE with CMake support ...	https://docs.espressif.com/projects/esp-idf/en/v4.4.7/esp32/get-started/windows-setup.html	0
506	Standard Setup of Toolchain for Windows - ESP32-S3 - — ESP-IDF ...	\N	\N	\N	For the remaining Getting Started steps, we are going to use the Windows Command Prompt. ESP-IDF Tools Installer also creates a shortcut in the Start menu to ...	https://docs.espressif.com/projects/esp-idf/en/stable/esp32s3/get-started/windows-setup.html	0
507	Get Started - ESP32-S2 - — ESP-IDF Programming Guide v4.4.5 ...	\N	\N	\N	Other ESP-IDF Versions are also available. Introduction . ESP32-S2 is a system on a chip that integrates the following features: Wi-Fi (2.4 ...	https://docs.espressif.com/projects/esp-idf/en/v4.4.5/esp32s2/get-started/index.html	0
508	Get Started - ESP32 - — ESP-IDF Programming Guide v5.1-rc1 ...	\N	\N	\N	Other ESP-IDF Versions are also available. Introduction . ESP32 is a system on a chip that integrates the following features: Wi-Fi (2.4 GHz band).	https://docs.espressif.com/projects/esp-idf/en/v5.1-rc1/esp32/get-started/index.html	0
509	esp-idf/README.md at master · espressif/esp-idf · GitHub	\N	\N	\N	Espressif IoT Development Framework. Official development framework for Espressif SoCs. - esp-idf/README.md at master · espressif/esp-idf.	https://github.com/espressif/esp-idf/blob/master/README.md	0
510	esp-idf/examples/openthread/ot_rcp/README.md at master ...	\N	\N	\N	Espressif IoT Development Framework. Official development framework for Espressif SoCs. - esp-idf/examples/openthread/ot_rcp/README.md at master ...	https://github.com/espressif/esp-idf/blob/master/examples/openthread/ot_rcp/README.md	0
511	esp-idf/examples/system/console/README.md at master · espressif ...	\N	\N	\N	This example illustrates lower-level APIs for line editing and autocompletion ( linenoise ), argument parsing ( argparse3 ) and command registration ( ...	https://github.com/espressif/esp-idf/blob/master/examples/system/console/README.md	0
512	Standard Toolchain Setup for Linux and macOS - ESP32 - — ESP ...	\N	\N	\N	The scripts introduced in this step install compilation tools required by ESP-IDF inside the user home directory: $HOME/.espressif on Linux. If you wish to ...	https://docs.espressif.com/projects/esp-idf/en/stable/esp32/get-started/linux-macos-setup.html	0
513	Get Started - - — ESP-IDF Programming Guide release-v4.0 ...	\N	\N	\N	This is documentation for branch release/v4.0 of ESP-IDF. Other ESP-IDF Versions are also available. Introduction¶. ESP32 is a system ...	https://docs.espressif.com/projects/esp-idf/en/release-v4.0/get-started/index.html	0
514	Arduino as an ESP-IDF component - - — Arduino ESP32 latest ...	\N	\N	\N	If you plan to use these modified settings multiple times, for different projects and targets, you can recompile the Arduino core with the new settings using ...	https://docs.espressif.com/projects/arduino-esp32/en/latest/esp-idf_component.html	0
515	FreeRTOS Overview - ESP32 - — ESP-IDF Programming Guide v5 ...	\N	\N	\N	This document provides an overview of the FreeRTOS component, the different ... ESP-IDF FreeRTOS) or the official Amazon SMP FreeRTOS documentation.	https://docs.espressif.com/projects/esp-idf/en/stable/esp32/api-reference/system/freertos.html	0
516	Migration from 2.x to 3.0 - - — Arduino ESP32 latest documentation	\N	\N	\N	X (based on ESP-IDF 4.4) to version 3.0 (based on ESP-IDF 5.1) of the Arduino ESP32 core. ... 0 or newer releases. For more information about all changes ...	https://docs.espressif.com/projects/arduino-esp32/en/latest/migration_guides/2.x_to_3.0.html	0
517	ESP-IDF Versions - ESP32 - — ESP-IDF Programming Guide v5.5.1 ...	\N	\N	\N	There you can find release notes, links to each version of the documentation, and instructions for obtaining each version. Another place to find documentation ...	https://docs.espressif.com/projects/esp-idf/en/stable/esp32/versions.html	0
518	Build System - ESP32 - — ESP-IDF Programming Guide v5.5.1 ...	\N	\N	\N	This document explains the implementation of the ESP-IDF build system and the concept of "components". Read this document if you want to know how to organize ...	https://docs.espressif.com/projects/esp-idf/en/stable/esp32/api-guides/build-system.html	0
519	LED Control (LEDC) - ESP32 - — ESP-IDF Programming Guide v5 ...	\N	\N	\N	Each group of channels is also able to use different clock sources. The PWM controller can automatically increase or decrease the duty cycle gradually, allowing ...	https://docs.espressif.com/projects/esp-idf/en/stable/esp32/api-reference/peripherals/ledc.html	0
520	ESP-IDF Programming Guide - ESP32	\N	\N	\N	ESP-IDF Programming Guide . [中文]. This is the documentation for Espressif IoT Development Framework (esp-idf). ESP-IDF is the official development ...	https://docs.espressif.com/projects/esp-idf/en/stable/esp32/index.html	0
521	Sleep Modes - ESP32 - — ESP-IDF Programming Guide v5.5.1 ...	\N	\N	\N	RTC peripherals or RTC memories do not need to be powered on during sleep in this wakeup mode. esp_sleep_enable_timer_wakeup() function can be used to enable ...	https://docs.espressif.com/projects/esp-idf/en/stable/esp32/api-reference/system/sleep_modes.html	0
522	ESP-IDF Versions - - — ESP-IDF Programming Guide release-v3.3 ...	\N	\N	\N	In order to maximize the time between updates to new ESP-IDF versions, use the latest stable Long Term Support release version. This version can be found on the ...	https://docs.espressif.com/projects/esp-idf/en/release-v3.3/versions.html	0
523	ESP-IDF Versions - ESP32 - — ESP-IDF Programming Guide v4.3-rc ...	\N	\N	\N	Releases¶. The documentation for the current stable release version can always be found at this URL: https://docs.espressif.com/projects/esp-idf/en/stable/.	https://docs.espressif.com/projects/esp-idf/en/v4.3-rc/esp32/versions.html	0
524	ESP-NOW - ESP32 - — ESP-IDF Programming Guide v5.5.1 ...	\N	\N	\N	stable (v5.5.1), v5.4.3, v5.3.4, v5.2.6, v5.1.6, Pre-Release Versions, master ... ESP-IDF Versions · Resources · Copyrights and Licenses · About · Switch Between ...	https://docs.espressif.com/projects/esp-idf/en/stable/esp32/api-reference/network/esp_now.html	0
525	API Reference - ESP32 - — ESP-IDF Programming Guide v5.5.1 ...	\N	\N	\N	stable (v5.5.1), v5.4.3, v5.3.4, v5.2.6, v5.1.6, Pre-Release Versions, master ... ESP-IDF Versions · Resources · Copyrights and Licenses · About · Switch Between ...	https://docs.espressif.com/projects/esp-idf/en/stable/esp32/api-reference/index.html	0
526	BLE throughput woes (IDFGH-12642) · Issue #13637 · espressif/esp ...	\N	\N	\N	Apr 18, 2024 ... Answers checklist. I have read the documentation ESP-IDF Programming Guide and the issue is not addressed there. I have updated my IDF ...	https://github.com/espressif/esp-idf/issues/13637	0
527	Multi-Target Build ? (IDFGH-12410) · Issue #13435 · espressif/esp-idf	\N	\N	\N	Mar 21, 2024 ... Press space again to drop the item in its new position, or press escape to cancel. ... diplfranzhoepfinger commented on Jun 8, 2024. @ ...	https://github.com/espressif/esp-idf/issues/13435	0
528	Espressif-IDE Workshop · Developer Portal	\N	\N	\N	Jun 3, 2024 ... This hands-on series of workshops introduces the Espressif IoT Development Framework (ESP-IDF) through the Integrated Development Environments (IDE).	https://developer.espressif.com/workshops/espressif-ide/	0
529	Advisories | Espressif Systems	\N	\N	\N	... decrease in Wi-Fi transmit power in certain ESP-IDF versions. V1.0, AR2024-002, Bugs, 2024.07.09, Fixed. End-of-Life Advisory for ESP-IDF v4.4 Release ...	https://www.espressif.com/en/support/documents/advisories	0
530	Issue selecting COM port in IDE - ESP32 Forum	\N	\N	\N	Aug 9, 2024 ... Mon Sep 02, 2024 11:01 am. Hi, I'm one of the contributors to the ESP-IDF VS Code extension. I'm not sure when you have tried the extension ...	https://esp32.com/viewtopic.php?t=41293	0
578	maintainers - RDoc Documentation	\N	\N	\N	Language core features including security; Evaluator; Core classes; Standard Library Maintainers; Libraries; lib/mkmf.rb; lib/rubygems.rb, lib/rubygems/*; lib ...	https://ruby-doc.org/3.3.5/maintainers_md.html	0
531	esp32 - Running Multiple Versions of ESP-IDF concurrently - Stack ...	\N	\N	\N	Mar 23, 2023 ... Let's assume you wish to install ESP-IDF v4 into ~/espressif/v4 and v5 into ~/espressif/v5 . First install v4: $ export IDF_TOOLS_PATH="$HOME/ ...	https://stackoverflow.com/questions/75819503/running-multiple-versions-of-esp-idf-concurrently	0
532	Implementation of an Internet of Things Architecture to Monitor ...	\N	\N	\N	This ESP32-C6 based air quality monitoring end device is developed using ESP-IDF (Espressif IoT Development Framework). This SDK (Software Development Kit) is ...	https://pmc.ncbi.nlm.nih.gov/articles/PMC11945692/	0
533	esp32 - ninja: error: loading 'build.ninja': The system cannot find the ...	\N	\N	\N	May 19, 2022 ... answered Mar 30, 2024 at 8:39. Michael B. Currie's user avatar ... I encountered similar error when using esp-idf with Espressif-IDE.	https://stackoverflow.com/questions/72299754/ninja-error-loading-build-ninja-the-system-cannot-find-the-file-specified	0
534	Side Project Announcement: NeoLED for ESP32! : r/esp32	\N	\N	\N	Nov 13, 2024 ... How does it compare to the driver in esp-idf/examples/get-started/blink/managed_components/espressif__led_strip? Edit: having looked at it ...	https://www.reddit.com/r/esp32/comments/1gqafz9/side_project_announcement_neoled_for_esp32/	0
535	Meredith Whittaker | cafiac.com	\N	\N	\N	2025-03-12 10:44:32 RT @AboutSignalNL: Zit je niet op Signal, want "ik heb toch ... 2022-10-18 20:45:53 RT @DecoderPod: Why did Signal drop SMS? Signal ...	https://cafiac.com/?q=fr/IAExpert/meredith-whittaker	0
536	Recommendations from the 2023 International Evidence-based ...	\N	\N	\N	What is the recommended assessment and management of those with polycystic ovary syndrome (PCOS).	https://www.asrm.org/practice-guidance/practice-committee-documents/recommendations-from-the-2023-international-evidence-based-guideline-for-the-assessment-and-management-of-polycystic-ovary-syndrome/	0
537	Expert Opinion on Current Trends in the Use of Insulin in the ...	\N	\N	\N	Mar 12, 2024 ... As specified in the 2023 ADA Standards of Care, BI alone is the most convenient initial insulin treatment and can be added to metformin or other ...	https://pmc.ncbi.nlm.nih.gov/articles/PMC11043254/	0
538	IWGDF Guidelines on the prevention and management of diabetes ...	\N	\N	\N	The burden of foot disease and amputations is increasing at a rapid rate, and comparatively more so in middle to lower income countries. These guidelines also ...	https://iwgdfguidelines.org/wp-content/uploads/2023/07/IWGDF-Guidelines-2023.pdf	0
539	2025 Article IV Consultation-Press Release; Staff Report; and ...	\N	\N	\N	Jul 18, 2025 ... ... contribution to growth is projected to decline ... The capital account was balanced at around 0 in 2024 (lower than in 2023) amid lower receipt of ...	https://www.imf.org/-/media/files/publications/cr/2025/english/1itaea2025001-source-pdf.pdf	0
540	Israel Defense Forces - Wikipedia	\N	\N	\N	The Israel Defense Forces alternatively referred to by the Hebrew-language acronym Tzahal (צה״ל), is the national military of the State of Israel.	https://en.wikipedia.org/wiki/Israel_Defense_Forces	0
541	Economic Survey 2023-24	\N	\N	\N	Jul 1, 2024 ... ... 2023-24. Government of India. Ministry of Finance. Department of Economic Affairs. Economic Division. North Block. New Delhi-110001. July, 2024 ...	https://www.indiabudget.gov.in/budget2024-25/economicsurvey/doc/echapter.pdf	0
542	usb_host_lib example gets stuck trying to connect Novation ...	\N	\N	\N	Jun 7, 2023 ... ... ESP-IDF 4.4.7 and failed to compile the example. ... Dazza0 commented on Jun 16, 2024. @Dazza0 · Dazza0 · on Jun 16, 2024. Contributor. More ...	https://github.com/espressif/esp-idf/issues/11616	0
543	Annual Report 2024-25	\N	\N	\N	Aug 31, 2025 ... 7.8.2 In GII 2024, India topped among 38 lower middle income ... the year 2023-2024, two (2) SICLD applications were filed, while ...	https://www.dpiit.gov.in/static/uploads/2025/06/3d9c9c2daeefb97bb9ce964370938b71.pdf	0
544	Linking extreme rainfall to suspended sediment fluxes in a ...	\N	\N	\N	Sep 10, 2025 ... sediment transport (Schmidt et al., 2023, 2024), the timing and ... calculate IDF curves from a single extreme value distribution (see ...	https://egusphere.copernicus.org/preprints/2025/egusphere-2025-3683/egusphere-2025-3683.pdf	0
545	Delta Academy Charter School I. Executive Summary A brief ...	\N	\N	\N	Jan 22, 2025 ... drop below five (5) directors, the only action that may ... employee/employer contribution plan for the years ended June 30, 2024, 2023 and.	https://charterschools.nv.gov/uploadedFiles/CharterSchoolsnvgov/content/News/2025/240125-Delta-Academy-Transfer-Application.pdf	0
546	Configuration Options Reference - ESP32 - — ESP-IDF ...	\N	\N	\N	... ESP-IDF configurations. Performing constant time operations protect the ECC ... Found in: Component config > LWIP > LWIP RAW API. The maximum number of ...	https://docs.espressif.com/projects/esp-idf/en/stable/esp32/api-reference/kconfig-reference.html	0
547	lwIP - ESP32-S3 - — ESP-IDF Programming Guide v5.5.1 ...	\N	\N	\N	A number of ESP-IDF examples show how to use the BSD Sockets APIs: protocols/sockets/non_blocking demonstrates how to configure and run a non-blocking TCP ...	https://docs.espressif.com/projects/esp-idf/en/stable/esp32s3/api-guides/lwip.html	0
548	System Time - ESP32 - — ESP-IDF Programming Guide v5.5.1 ...	\N	\N	\N	However, users can also select a different setting via the CONFIG_LIBC_TIME_SYSCALL configuration option. ... Therefore SNTP-related functions in ESP-IDF are ...	https://docs.espressif.com/projects/esp-idf/en/stable/esp32/api-reference/system/system_time.html	0
549	Configuration Options Reference - ESP32-S3 - — ESP-IDF ...	\N	\N	\N	... ESP-IDF configurations. Performing constant time operations protect the ECC ... Found in: Component config > LWIP > LWIP RAW API. The maximum number of ...	https://docs.espressif.com/projects/esp-idf/en/stable/esp32s3/api-reference/kconfig-reference.html	0
550	Configuration Options — ESP-IDF Programming Guide v3.1.5 ...	\N	\N	\N	ESP-IDF uses Kconfig system to provide a compile-time configuration mechanism. ... Component config > LWIP. CONFIG_LWIP_ETHARP_TRUST_IP_MAC ¶. Enable LWIP ...	https://docs.espressif.com/projects/esp-idf/en/v3.1.5/api-reference/kconfig.html	0
551	Support for External RAM - ESP32 - — ESP-IDF Programming Guide ...	\N	\N	\N	Once the external RAM is initialized at startup, ESP-IDF can be configured to integrate the external RAM in several ways: ... lwIP, net80211, libpp, ...	https://docs.espressif.com/projects/esp-idf/en/stable/esp32/api-guides/external-ram.html	0
552	Configuration Options — ESP-IDF Programming Guide v3.0.8-30 ...	\N	\N	\N	ESP-IDF uses Kconfig system to provide a compile-time configuration mechanism. ... LWIP_MAX_RAW_PCBS¶. Maximum LWIP RAW PCBs. Found in: Component config > LWIP > ...	https://docs.espressif.com/projects/esp-idf/en/release-v3.0/api-reference/kconfig.html	0
553	Configuration Options - - — ESP-IDF Programming Guide release ...	\N	\N	\N	ESP-IDF uses Kconfig system to provide a compile-time configuration mechanism. ... CONFIG_LWIP_MAX_RAW_PCBS¶. Maximum LWIP RAW PCBs. Found in: Component config > ...	https://docs.espressif.com/projects/esp-idf/en/release-v3.3/api-reference/kconfig.html	0
554	Running ESP-IDF Applications on Host - ESP32 - — ESP-IDF ...	\N	\N	\N	Easier automation and setup for software testing. Large number of tools for code and runtime analysis, e.g., Valgrind. A large number of ESP-IDF components ...	https://docs.espressif.com/projects/esp-idf/en/stable/esp32/api-guides/host-apps.html	0
555	Get Started (CMake) — ESP-IDF Programming Guide v3.3 ...	\N	\N	\N	Step 1. Set up Toolchain for Windows, Linux or MacOS · Step 2. Get ESP-IDF · Step 3. Set Environment Variables · Step 4. Install the Required Python Packages ...	https://docs.espressif.com/projects/esp-idf/en/v3.3/get-started-cmake/index.html	0
556	Setup Windows Toolchain from Scratch (CMake) — ESP-IDF ...	\N	\N	\N	If you encounter any gaps or bugs, please report them in the Issues section of the ESP-IDF repository. The CMake-based build system will become the default ...	https://docs.espressif.com/projects/esp-idf/en/v3.3.1/get-started-cmake/windows-setup-scratch.html	0
557	Add IDF_PATH & idf.py PATH to User Profile (CMake) — ESP-IDF ...	\N	\N	\N	If you encounter any gaps or bugs, please report them in the Issues section of the ESP-IDF repository. The CMake-based build system will become the default ...	https://docs.espressif.com/projects/esp-idf/en/v3.3/get-started-cmake/add-idf_path-to-profile.html	0
558	Set up OpenOCD for Windows — ESP-IDF Programming Guide v3.3 ...	\N	\N	\N	... Windows (CMake) with the ESP-IDF Tools Installer V1.2 or newer, then by default you will already have openocd installed. ESP-IDF Tools Installer adds ...	https://docs.espressif.com/projects/esp-idf/en/v3.3/api-guides/jtag-debugging/setup-openocd-windows.html	0
559	Setup Windows Toolchain from Scratch - ESP32 - — ESP-IDF ...	\N	\N	\N	This is a step-by-step alternative to running the ESP-IDF Tools Installer for the CMake-based build system. Installing all of the tools by hand allows more ...	https://docs.espressif.com/projects/esp-idf/en/release-v4.2/esp32/get-started/windows-setup-scratch.html	0
560	Standard Setup of Toolchain for Mac OS - ESP32 - — ESP-IDF ...	\N	\N	\N	Install Prerequisites ... ESP-IDF will use the version of Python installed by default on macOS ... install pip ... sudo easy_install pip ... install pyserial ... pip ...	https://docs.espressif.com/projects/esp-idf/en/v4.2/esp32/get-started/macos-setup.html	0
561	Standard Setup of Toolchain for macOS - ESP32 - — ESP-IDF ...	\N	\N	\N	ESP-IDF will use the version of Python installed by default on macOS. install pip: sudo easy_install pip. install CMake & Ninja build ...	https://docs.espressif.com/projects/esp-idf/en/release-v4.2/esp32/get-started/macos-setup.html	0
562	Install ESP-IDF and Tools - - — ESP-IDF Extension for VSCode ...	\N	\N	\N	For macOS/Linux users, select the Python executable to create the ESP-IDF Python virtual environment. Click Install to begin downloading and installing ESP-IDF ...	https://docs.espressif.com/projects/vscode-esp-idf-extension/en/latest/installation.html	0
563	Standard Setup of Toolchain for Mac OS (CMake) — ESP-IDF ...	\N	\N	\N	ESP-IDF will use the version of Python installed by default on Mac OS. install pip: sudo easy_install pip. install pyserial:.	https://docs.espressif.com/projects/esp-idf/en/release-v3.2/get-started-cmake/macos-setup.html	0
564	Standard Toolchain Setup for Linux and macOS - ESP32 - — ESP ...	\N	\N	\N	Install Prerequisites . In order to use ESP-IDF with the ESP32, you need to install some software packages based on your Operating System. This setup guide will ...	https://docs.espressif.com/projects/esp-idf/en/v5.0.1/esp32/get-started/linux-macos-setup.html	0
565	Standard Setup of Toolchain for Mac OS — ESP-IDF Programming ...	\N	\N	\N	To carry on with development environment setup, proceed to section Get ESP-IDF. Related Documents¶. Setup Toolchain for Mac OS from Scratch · Next ...	https://docs.espressif.com/projects/esp-idf/en/release-v3.0/get-started/macos-setup.html	0
566	Setup Toolchain for Mac OS from Scratch - ESP32 - — ESP-IDF ...	\N	\N	\N	Setup Toolchain for Mac OS from Scratch; Edit on GitHub. Note. You are reading the documentation for an ESP-IDF release version that is end of life.	https://docs.espressif.com/projects/esp-idf/en/release-v4.3/esp32/get-started/macos-setup-scratch.html	0
567	class ERB - Documentation for Ruby 2.3.0	\N	\N	\N	Introduction; Recognized Tags; Options; Character encodings; Examples; Plain ... Ruby language!</b></li> <li><b>Ignores Perl, Java, and all C variants.</b> ...	https://docs.ruby-lang.org/en/2.3.0/ERB.html	0
568	class ERB - RDoc Documentation	\N	\N	\N	Introduction; Recognized Tags; Options; Character encodings; Examples; Plain ... Ruby language!</b></li> <li><b>Ignores Perl, Java, and all C variants.</b> ...	https://docs.ruby-lang.org/en/3.0/ERB.html	0
569	Ruby 3.0.0 Released	\N	\N	\N	Dec 25, 2020 ... TypeProf is experimental and not so mature yet; only a subset of the Ruby language is supported, and the detection of type errors is limited.	https://www.ruby-lang.org/en/news/2020/12/25/ruby-3-0-0-released/	0
570	About Ruby	\N	\N	\N	Ruby-Talk, the primary mailing list for discussion of the Ruby language, climbed to an average of 200 messages per day in 2006. It has dropped in recent ...	https://www.ruby-lang.org/en/about/	0
571	class ERB - Documentation for Ruby 4.0	\N	\N	\N	Responds to Ruby commands...", 999.95 ) toy.add_feature('Listens for verbal commands in the Ruby language!') toy.add_feature('Ignores Perl ...	https://docs.ruby-lang.org/en/master/ERB.html	0
572	Feature #19744: Namespace on read - Ruby - Ruby Issue Tracking ...	\N	\N	\N	The more I read this feature proposal, the more I see that it was thought from Ruby language perspective but not fully scoped from the Ruby ecosystem ...	https://bugs.ruby-lang.org/issues/19744	0
573	File: maintainers.rdoc [Ruby 2.4.5]	\N	\N	\N	They need consensus on ruby-core/ruby-dev before changing/adding. Some of submaintainers have commit right, others don't. Language core features including ...	https://ruby-doc.org/core-2.4.5/doc/maintainers_rdoc.html	0
574	File: maintainers.rdoc [Ruby 2.6.8]	\N	\N	\N	They need consensus on ruby-core/ruby-dev before changing/adding. Some of submaintainers have commit right, others don't. Language core features including ...	https://ruby-doc.org/core-2.6.8/doc/maintainers_rdoc.html	0
575	maintainers - RDoc Documentation	\N	\N	\N	Language core features including security; Evaluator; Core classes; Standard Library Maintainers; Libraries; Extensions; Default gems Maintainers; Libraries ...	https://ruby-doc.org/3.2.2/maintainers_rdoc.html	0
576	GitLab vs GitHub: The Ultimate 2025 Comparison - Ruby-Doc.org	\N	\N	\N	Jul 29, 2025 ... While both platforms support Git, the GitLab vs GitHub debate becomes sharper when diving into core feature sets, hosting options, community ...	https://ruby-doc.org/blog/gitlab-vs-github-the-ultimate-2025-comparison/	0
577	File: maintainers.rdoc [Ruby 3.0.3]	\N	\N	\N	They need consensus on ruby-core/ruby-dev before changing/adding. Some of submaintainers have commit right, others don't. Language core features including ...	https://ruby-doc.org/core-3.0.3/doc/maintainers_rdoc.html	0
579	File: contributing.rdoc [Ruby 2.6]	\N	\N	\N	Released versions in security mode will not merge feature changes. Search for previous discussions on ruby-core to verify the maintenance policy. Patches must ...	https://ruby-doc.org/core-2.6/doc/contributing_rdoc.html	0
580	Gitflow vs GitHub Flow: A Comprehensive Comparison for ...	\N	\N	\N	Jul 29, 2025 ... Main branches: master (or main ): Represents production-ready code. develop : Serves as an integration branch for features; the next release ...	https://ruby-doc.org/blog/gitflow-vs-github-flow-a-comprehensive-comparison-for-development-teams/	0
581	NEWS - RDoc Documentation	\N	\N	\N	New features; New optimizations; Miscellaneous changes. Show/hide navigation ... core processor utilization. [Feature #20876]. GC. GC.config added to allow ...	https://ruby-doc.org/3.4.1/ruby_3_4_1/NEWS_md.html	0
582	NEWS-2.1.0 - RDoc Documentation	\N	\N	\N	Core classes updates (outstanding ones only); Core classes compatibility issues (excluding feature bug fixes); Stdlib updates (outstanding ones only); Stdlib ...	https://ruby-doc.org/3.1.6/NEWS-2_1_0.html	0
583	Official Ruby FAQ	\N	\N	\N	If you like Python, you may or may not be put off by the huge difference in design philosophy between Python and Ruby/Perl. ... Mailing Lists: Talk about Ruby ...	https://www.ruby-lang.org/en/documentation/faq/2/	0
584	Bug #15794: Can not start Puma with Rails after bundle install - Ruby	\N	\N	\N	0/bundler/source/rubygems.rb 90 /Users/bacdo/.rvm/rubies/ruby-2.4.3/lib/ruby ... rake.rb 3412 /Users/bacdo/.rvm/gems/ruby-2.4.3/gems/bugsnag-5.4.1/lib ...	https://bugs.ruby-lang.org/issues/15794	0
585	Bug #20391: Segmentation fault at 0x0000000000000028 on Ruby ...	\N	\N	\N	Mar 21, 2024 ... 88 /usr/local/bundle/gems/bundler-2.4.18/lib/bundler/source/rubygems.rb ... rake-13.1.0/lib/rake/ext/core.rb 1047 /usr/local/lib/ruby/gems ...	https://bugs.ruby-lang.org/issues/20391	0
586	Bug #15623: Ruby 2.6.1 Segmentation Fault in on Phusion ...	\N	\N	\N	... bundler/rubygems_integration.rb:817 c:0004 p:0013 s:0047 e:000046 METHOD ... rails (forking...) * Loaded features: 0 enumerator.so 1 thread.rb 2 ...	https://bugs.ruby-lang.org/issues/15623	0
587	methods - Are there performance reasons to prefer size over length ...	\N	\N	\N	Nov 26, 2018 ... ... Ruby vs Rails. I also do not think that the answer is very straightforward in this case, as when getting counts for AR relations, pagination ...	https://stackoverflow.com/questions/53480273/are-there-performance-reasons-to-prefer-size-over-length-or-count-in-ruby	0
588	ruby on rails - Suppressing spaces in ERB template - Stack Overflow	\N	\N	\N	Mar 3, 2015 ... -%> behaves differently if using 'erb' vs 'erubis' libraries (ruby vs rails). ... What is the difference between <%, <%=, <%# and -%> in ...	https://stackoverflow.com/questions/28836504/suppressing-spaces-in-erb-template	0
589	Ruby vs Python 3 - Which programs are fastest? (Benchmarks Game)	\N	\N	\N	Ruby versus Python 3. How the programs are written matters! Always look at the source code. If the fastest programs are flagged possible hand-written vector ...	https://benchmarksgame-team.pages.debian.net/benchmarksgame/fastest/ruby-python3.html	0
590	Ruby vs PHP - Which programs are fastest? (Benchmarks Game)	\N	\N	\N	Ruby versus PHP. How the programs are written matters! Always look at the source code. If the fastest programs are flagged possible hand-written vector ...	https://benchmarksgame-team.pages.debian.net/benchmarksgame/fastest/ruby-php.html	0
591	Measured : Which programming language is fastest? (Benchmarks ...	\N	\N	\N	C gcc · —— Perl —— · Lua · Ruby · —— PHP —— · Java · Python · Ruby · —— Python —— · C++ g++ · Erlang · Go · Java · Java -Xint · JavaScript · Lua · PHP · Ruby.	https://benchmarksgame-team.pages.debian.net/benchmarksgame/index.html	0
592	reverse-complement - Which programs are fastest? (Benchmarks ...	\N	\N	\N	Ruby #4, 6.01, 3,079,053, 608, 11.59. 14, Java naot #5, 6.03, 1,100,202, 1115, 6.02. 15, * Haskell GHC #2, 6.55, 3,131,236, 998, 6.67. 15, C++ g++, 6.55 ...	https://benchmarksgame-team.pages.debian.net/benchmarksgame/performance/revcomp.html	0
593	Node.js vs Java - Which programs are fastest? (Benchmarks Game)	\N	\N	\N	Ruby. How the programs are written matters! Always look at the source code. If the fastest programs are flagged * possible hand-written vector instructions ...	https://benchmarksgame-team.pages.debian.net/benchmarksgame/fastest/node-javavm.html	0
594	Node.js vs C# - Which programs are fastest? (Benchmarks Game)	\N	\N	\N	Ruby. How the programs are written matters! Always look at the source code. If the fastest programs are flagged * possible hand-written vector instructions ...	https://benchmarksgame-team.pages.debian.net/benchmarksgame/fastest/node-csharpcore.html	0
595	How programs are measured (Benchmarks Game)	\N	\N	\N	Ruby, 583. Python 3, 585. Julia, 634. Chapel, 646. Racket, 696. JavaScript, 698. OCaml, 741. Erlang, 798. Go, 831. Dart, 847. Smalltalk, 871. Haskell, 892. Java ...	https://benchmarksgame-team.pages.debian.net/benchmarksgame/how-programs-are-measured.html	0
596	Index of Files, Classes & Methods in Ruby 2.4.8 (Ruby 2.4.8)	\N	\N	\N	#iterator? (Kernel). #itself (Object). #join (Array). #join (Thread) ... #yield (Proc). #yydebug (Ripper). #yydebug= (Ripper). #zero? (File::Stat). #zero ...	https://ruby-doc.org/core-2.4.8/index.html	0
597	Ruby 2.2.10	\N	\N	\N	Feb 2, 2010 ... #iterator? (Kernel). #itself (Object). #join (Array). #join (Thread) ... #yield (Proc). #zero? (File::Stat). #zero? (FileTest). #zero? (Fixnum).	https://ruby-doc.org/core-2.2.10/	0
598	Ruby 1.9.1	\N	\N	\N	#iterator? (Kernel). #join (Array). #join (Thread). #key (Hash). #key? (Hash) ... #yield (Proc). #zero? (File::Stat). #zero? (FileTest). #zero? (Fixnum). #zero ...	https://ruby-doc.org/core-1.9.1/	0
599	Ruby 3.1.1	\N	\N	\N	#iterator? (Kernel). #itself (Object). #join (Array). #join (Thread). #keep_if ... #yield (Proc). #yield_self (Kernel). #yydebug (Ripper). #yydebug= (Ripper).	https://ruby-doc.org/core-3.1.1/	0
600	File: NEWS-1.9.1 [Ruby 3.1.2]	\N	\N	\N	... Enumerable::Enumerator, compatibility alias of Enumerator, is removed. o ... Proc#yield o Passing blocks to #[] o Proc#lambda? o Proc#curry * Fiber ...	https://ruby-doc.org/core-3.1.2/ruby-3_1_2/doc/NEWS-1_9_1.html	0
601	Module: Kernel (Ruby 2.5.1)	\N	\N	\N	Apr 9, 2003 ... #autoload? ... #block_given? ... #exit! ... #iterator? #lambda; #load; #local_variables; #loop; #open; #p; #print; #printf; #proc ...	https://ruby-doc.org/core-2.5.1/Kernel.html	0
602	Class: Method (Ruby 2.5.6)	\N	\N	\N	They may be used to invoke the method within the object, and as a block associated with an iterator. ... See also Proc#lambda? . VALUE rb_method_call(int argc, ...	https://ruby-doc.org/core-2.5.6/Method.html	0
603	Module: Kernel (Ruby 2.4.9)	\N	\N	\N	Apr 9, 2003 ... #autoload? ... #block_given? ... #exit! ... #iterator? #lambda; #load; #local_variables; #loop; #open; #p; #print; #printf; #proc ...	https://ruby-doc.org/core-2.4.9/Kernel.html	0
604	The Ruby Language FAQ	\N	\N	\N	... iterator that calls yield ), or by using the Proc.call method. 4.12 Why did ... ( proc and lambda are effectively synonyms.) def myIterator Proc.new ...	https://ruby-doc.org/docs/ruby-doc-bundle/FAQ/FAQ.html	0
605	Class: CSV (Ruby 2.7.3)	\N	\N	\N	... yield csv # yield for appending csv.string # return final String end ... Support for Enumerable. The data source must be open for reading. # File csv ...	https://ruby-doc.org/stdlib-2.7.3/libdoc/csv/rdoc/CSV.html	0
\.


--
-- Data for Name: source_sections; Type: TABLE DATA; Schema: public; Owner: nr
--

COPY public.source_sections (id, document_id, tag_id, section_title, content, section_number, created_at) FROM stdin;
440	439	\N	\N	null	\N	2025-12-10 18:03:43.674678
441	440	\N	\N	null	\N	2025-12-10 18:03:43.684795
442	441	\N	\N	null	\N	2025-12-10 18:03:43.691941
443	442	\N	\N	null	\N	2025-12-10 18:03:43.698248
444	443	\N	\N	null	\N	2025-12-10 18:03:43.705386
445	444	\N	\N	null	\N	2025-12-10 18:03:43.711406
446	445	\N	\N	null	\N	2025-12-10 18:03:43.718529
447	446	\N	\N	null	\N	2025-12-10 18:03:43.725027
448	447	\N	\N	null	\N	2025-12-10 18:03:43.731188
449	448	\N	\N	null	\N	2025-12-10 18:03:43.73743
450	449	\N	\N	null	\N	2025-12-10 18:03:46.201014
451	450	\N	\N	null	\N	2025-12-10 18:03:46.207545
452	451	\N	\N	null	\N	2025-12-10 18:03:46.215613
453	452	\N	\N	null	\N	2025-12-10 18:03:46.222686
454	453	\N	\N	null	\N	2025-12-10 18:03:46.229063
455	454	\N	\N	null	\N	2025-12-10 18:03:46.235281
456	455	\N	\N	null	\N	2025-12-10 18:03:46.243752
457	456	\N	\N	null	\N	2025-12-10 18:03:46.249428
458	457	\N	\N	null	\N	2025-12-10 18:03:46.255021
459	458	\N	\N	null	\N	2025-12-10 18:03:46.261104
460	459	\N	\N	null	\N	2025-12-10 18:04:28.537582
461	460	\N	\N	null	\N	2025-12-10 18:04:28.544579
462	461	\N	\N	null	\N	2025-12-10 18:04:28.550987
463	462	\N	\N	null	\N	2025-12-10 18:04:28.558542
464	463	\N	\N	null	\N	2025-12-10 18:04:28.564925
465	464	\N	\N	null	\N	2025-12-10 18:04:28.571007
466	465	\N	\N	null	\N	2025-12-10 18:04:28.577947
467	466	\N	\N	null	\N	2025-12-10 18:04:28.584239
468	467	\N	\N	null	\N	2025-12-10 18:04:28.590332
469	468	\N	\N	null	\N	2025-12-10 18:04:28.596746
470	469	\N	\N	null	\N	2025-12-10 18:04:30.774637
471	470	\N	\N	null	\N	2025-12-10 18:04:30.781871
472	471	\N	\N	null	\N	2025-12-10 18:04:30.788057
473	472	\N	\N	null	\N	2025-12-10 18:04:30.795979
474	473	\N	\N	null	\N	2025-12-10 18:04:30.80223
475	474	\N	\N	null	\N	2025-12-10 18:04:30.808857
476	475	\N	\N	null	\N	2025-12-10 18:04:30.815286
477	476	\N	\N	null	\N	2025-12-10 18:04:30.821484
478	477	\N	\N	null	\N	2025-12-10 18:04:32.910752
479	478	\N	\N	null	\N	2025-12-10 18:04:32.917087
480	479	\N	\N	null	\N	2025-12-10 18:04:32.923157
481	480	\N	\N	null	\N	2025-12-10 18:04:32.930195
482	481	\N	\N	null	\N	2025-12-10 18:04:32.936481
483	482	\N	\N	null	\N	2025-12-10 18:04:32.941711
484	483	\N	\N	null	\N	2025-12-10 18:04:39.363117
485	484	\N	\N	null	\N	2025-12-10 18:04:39.369707
486	485	\N	\N	null	\N	2025-12-10 18:04:39.376773
487	486	\N	\N	null	\N	2025-12-10 18:04:39.384081
488	487	\N	\N	null	\N	2025-12-10 18:04:39.3909
489	488	\N	\N	null	\N	2025-12-10 18:04:39.397135
490	489	\N	\N	null	\N	2025-12-10 18:04:39.404507
491	490	\N	\N	null	\N	2025-12-10 18:04:39.41104
492	491	\N	\N	null	\N	2025-12-10 18:04:39.418385
493	492	\N	\N	null	\N	2025-12-10 18:04:41.492064
494	493	\N	\N	null	\N	2025-12-10 18:04:41.498972
495	494	\N	\N	null	\N	2025-12-10 18:04:41.50511
496	495	\N	\N	null	\N	2025-12-10 18:04:41.510664
497	496	\N	\N	null	\N	2025-12-10 18:04:41.518677
498	497	\N	\N	null	\N	2025-12-10 18:04:41.524255
499	498	\N	\N	null	\N	2025-12-10 18:04:41.530738
500	499	\N	\N	null	\N	2025-12-10 18:04:41.536476
501	500	\N	\N	null	\N	2025-12-10 18:04:41.542
502	501	\N	\N	null	\N	2025-12-10 18:45:51.182009
503	502	\N	\N	null	\N	2025-12-10 18:45:51.189411
504	503	\N	\N	null	\N	2025-12-10 18:45:51.195147
505	504	\N	\N	null	\N	2025-12-10 18:45:51.201515
506	505	\N	\N	null	\N	2025-12-10 18:45:51.207127
507	506	\N	\N	null	\N	2025-12-10 18:45:51.212903
508	507	\N	\N	null	\N	2025-12-10 18:45:51.21871
509	508	\N	\N	null	\N	2025-12-10 18:45:51.224373
510	509	\N	\N	null	\N	2025-12-10 18:45:53.414811
511	510	\N	\N	null	\N	2025-12-10 18:45:53.423372
512	511	\N	\N	null	\N	2025-12-10 18:45:53.43166
513	512	\N	\N	null	\N	2025-12-10 18:46:12.572569
514	513	\N	\N	null	\N	2025-12-10 18:46:12.580433
515	514	\N	\N	null	\N	2025-12-10 18:46:19.691987
516	515	\N	\N	null	\N	2025-12-10 18:46:19.697995
517	516	\N	\N	null	\N	2025-12-10 18:46:19.705148
518	517	\N	\N	null	\N	2025-12-10 18:46:19.71135
519	518	\N	\N	null	\N	2025-12-10 18:46:19.71862
520	519	\N	\N	null	\N	2025-12-10 18:46:19.724814
521	520	\N	\N	null	\N	2025-12-10 18:46:19.730142
522	521	\N	\N	null	\N	2025-12-10 18:46:19.736304
523	522	\N	\N	null	\N	2025-12-10 18:46:22.26859
524	523	\N	\N	null	\N	2025-12-10 18:46:22.27679
525	524	\N	\N	null	\N	2025-12-10 18:46:22.284101
526	525	\N	\N	null	\N	2025-12-10 18:46:22.290216
527	526	\N	\N	null	\N	2025-12-10 18:46:24.353204
528	527	\N	\N	null	\N	2025-12-10 18:46:24.360469
529	528	\N	\N	null	\N	2025-12-10 18:46:24.367085
530	529	\N	\N	null	\N	2025-12-10 18:46:24.372817
531	530	\N	\N	null	\N	2025-12-10 18:46:24.379203
532	531	\N	\N	null	\N	2025-12-10 18:46:24.385132
533	532	\N	\N	null	\N	2025-12-10 18:46:24.390894
534	533	\N	\N	null	\N	2025-12-10 18:46:24.397662
535	534	\N	\N	null	\N	2025-12-10 18:46:24.403703
536	535	\N	\N	null	\N	2025-12-10 18:46:26.359816
537	536	\N	\N	null	\N	2025-12-10 18:46:28.482015
538	537	\N	\N	null	\N	2025-12-10 18:46:28.489106
539	538	\N	\N	null	\N	2025-12-10 18:46:28.495422
540	539	\N	\N	null	\N	2025-12-10 18:46:28.500472
541	540	\N	\N	null	\N	2025-12-10 18:46:28.505502
542	541	\N	\N	null	\N	2025-12-10 18:46:28.511128
543	542	\N	\N	null	\N	2025-12-10 18:46:28.51651
544	543	\N	\N	null	\N	2025-12-10 18:46:28.521973
545	544	\N	\N	null	\N	2025-12-10 18:46:28.527555
546	545	\N	\N	null	\N	2025-12-10 18:46:28.533576
547	546	\N	\N	null	\N	2025-12-10 18:46:32.983619
548	547	\N	\N	null	\N	2025-12-10 18:46:32.989742
549	548	\N	\N	null	\N	2025-12-10 18:46:32.996611
550	549	\N	\N	null	\N	2025-12-10 18:46:33.002349
551	550	\N	\N	null	\N	2025-12-10 18:46:33.00782
552	551	\N	\N	null	\N	2025-12-10 18:46:33.014601
553	552	\N	\N	null	\N	2025-12-10 18:46:33.020833
554	553	\N	\N	null	\N	2025-12-10 18:46:33.027078
555	554	\N	\N	null	\N	2025-12-10 18:46:33.032861
556	555	\N	\N	null	\N	2025-12-10 18:46:35.141238
557	556	\N	\N	null	\N	2025-12-10 18:46:35.149827
558	557	\N	\N	null	\N	2025-12-10 18:46:35.157235
559	558	\N	\N	null	\N	2025-12-10 18:46:35.163641
560	559	\N	\N	null	\N	2025-12-10 18:46:35.170762
561	560	\N	\N	null	\N	2025-12-10 18:46:37.25841
562	561	\N	\N	null	\N	2025-12-10 18:46:37.265229
563	562	\N	\N	null	\N	2025-12-10 18:46:37.271258
564	563	\N	\N	null	\N	2025-12-10 18:46:37.277251
565	564	\N	\N	null	\N	2025-12-10 18:46:37.283349
566	565	\N	\N	null	\N	2025-12-10 18:46:37.289469
567	566	\N	\N	null	\N	2025-12-10 18:46:37.29497
568	567	\N	\N	null	\N	2025-12-11 13:27:26.726454
569	568	\N	\N	null	\N	2025-12-11 13:27:26.735767
570	569	\N	\N	null	\N	2025-12-11 13:27:26.741865
571	570	\N	\N	null	\N	2025-12-11 13:27:26.747982
572	571	\N	\N	null	\N	2025-12-11 13:27:26.754545
573	572	\N	\N	null	\N	2025-12-11 13:27:26.760738
574	573	\N	\N	null	\N	2025-12-11 13:27:29.255979
575	574	\N	\N	null	\N	2025-12-11 13:27:29.263137
576	575	\N	\N	null	\N	2025-12-11 13:27:29.269617
577	576	\N	\N	null	\N	2025-12-11 13:27:29.275688
578	577	\N	\N	null	\N	2025-12-11 13:27:29.281734
579	578	\N	\N	null	\N	2025-12-11 13:27:29.288368
580	579	\N	\N	null	\N	2025-12-11 13:27:29.294121
581	580	\N	\N	null	\N	2025-12-11 13:27:29.300128
582	581	\N	\N	null	\N	2025-12-11 13:27:29.306602
583	582	\N	\N	null	\N	2025-12-11 13:27:29.312951
584	583	\N	\N	null	\N	2025-12-11 13:27:48.851542
585	584	\N	\N	null	\N	2025-12-11 13:27:55.351196
586	585	\N	\N	null	\N	2025-12-11 13:27:55.358211
587	586	\N	\N	null	\N	2025-12-11 13:27:55.364312
588	587	\N	\N	null	\N	2025-12-11 13:28:02.611742
589	588	\N	\N	null	\N	2025-12-11 13:28:02.61958
590	589	\N	\N	null	\N	2025-12-11 13:28:09.042705
591	590	\N	\N	null	\N	2025-12-11 13:28:09.048398
592	591	\N	\N	null	\N	2025-12-11 13:28:09.054218
593	592	\N	\N	null	\N	2025-12-11 13:28:09.059815
594	593	\N	\N	null	\N	2025-12-11 13:28:09.065737
595	594	\N	\N	null	\N	2025-12-11 13:28:09.072115
596	595	\N	\N	null	\N	2025-12-11 13:28:09.077682
597	596	\N	\N	null	\N	2025-12-11 13:28:13.426646
598	597	\N	\N	null	\N	2025-12-11 13:28:13.434151
599	598	\N	\N	null	\N	2025-12-11 13:28:13.440661
600	599	\N	\N	null	\N	2025-12-11 13:28:13.446748
601	600	\N	\N	null	\N	2025-12-11 13:28:13.452598
602	601	\N	\N	null	\N	2025-12-11 13:28:13.458928
603	602	\N	\N	null	\N	2025-12-11 13:28:13.464361
604	603	\N	\N	null	\N	2025-12-11 13:28:13.470262
605	604	\N	\N	null	\N	2025-12-11 13:28:13.476057
606	605	\N	\N	null	\N	2025-12-11 13:28:13.48344
\.


--
-- Data for Name: tag_links; Type: TABLE DATA; Schema: public; Owner: nr
--

COPY public.tag_links (source_tag_id, target_tag_id, relation_type) FROM stdin;
\.


--
-- Data for Name: tags; Type: TABLE DATA; Schema: public; Owner: nr
--

COPY public.tags (id, name) FROM stdin;
\.


--
-- Name: embeddings_id_seq; Type: SEQUENCE SET; Schema: public; Owner: nr
--

SELECT pg_catalog.setval('public.embeddings_id_seq', 1, false);


--
-- Name: research_topics_id_seq; Type: SEQUENCE SET; Schema: public; Owner: nr
--

SELECT pg_catalog.setval('public.research_topics_id_seq', 16, true);


--
-- Name: source_documents_id_seq; Type: SEQUENCE SET; Schema: public; Owner: nr
--

SELECT pg_catalog.setval('public.source_documents_id_seq', 605, true);


--
-- Name: source_sections_id_seq; Type: SEQUENCE SET; Schema: public; Owner: nr
--

SELECT pg_catalog.setval('public.source_sections_id_seq', 606, true);


--
-- Name: tags_id_seq; Type: SEQUENCE SET; Schema: public; Owner: nr
--

SELECT pg_catalog.setval('public.tags_id_seq', 1, false);


--
-- Name: embeddings embeddings_pkey; Type: CONSTRAINT; Schema: public; Owner: nr
--

ALTER TABLE ONLY public.embeddings
    ADD CONSTRAINT embeddings_pkey PRIMARY KEY (id);


--
-- Name: research_topic_sections research_topic_sections_pkey; Type: CONSTRAINT; Schema: public; Owner: nr
--

ALTER TABLE ONLY public.research_topic_sections
    ADD CONSTRAINT research_topic_sections_pkey PRIMARY KEY (research_topic_id, section_id);


--
-- Name: research_topic_tags research_topic_tags_pkey; Type: CONSTRAINT; Schema: public; Owner: nr
--

ALTER TABLE ONLY public.research_topic_tags
    ADD CONSTRAINT research_topic_tags_pkey PRIMARY KEY (research_topic_id, tag_id);


--
-- Name: research_topics research_topics_name_key; Type: CONSTRAINT; Schema: public; Owner: nr
--

ALTER TABLE ONLY public.research_topics
    ADD CONSTRAINT research_topics_name_key UNIQUE (name);


--
-- Name: research_topics research_topics_pkey; Type: CONSTRAINT; Schema: public; Owner: nr
--

ALTER TABLE ONLY public.research_topics
    ADD CONSTRAINT research_topics_pkey PRIMARY KEY (id);


--
-- Name: section_tags section_tags_pkey; Type: CONSTRAINT; Schema: public; Owner: nr
--

ALTER TABLE ONLY public.section_tags
    ADD CONSTRAINT section_tags_pkey PRIMARY KEY (section_id, tag_id);


--
-- Name: source_documents source_documents_pkey; Type: CONSTRAINT; Schema: public; Owner: nr
--

ALTER TABLE ONLY public.source_documents
    ADD CONSTRAINT source_documents_pkey PRIMARY KEY (id);


--
-- Name: source_sections source_sections_pkey; Type: CONSTRAINT; Schema: public; Owner: nr
--

ALTER TABLE ONLY public.source_sections
    ADD CONSTRAINT source_sections_pkey PRIMARY KEY (id);


--
-- Name: tag_links tag_links_source_tag_id_target_tag_id_key; Type: CONSTRAINT; Schema: public; Owner: nr
--

ALTER TABLE ONLY public.tag_links
    ADD CONSTRAINT tag_links_source_tag_id_target_tag_id_key UNIQUE (source_tag_id, target_tag_id);


--
-- Name: tags tags_name_key; Type: CONSTRAINT; Schema: public; Owner: nr
--

ALTER TABLE ONLY public.tags
    ADD CONSTRAINT tags_name_key UNIQUE (name);


--
-- Name: tags tags_pkey; Type: CONSTRAINT; Schema: public; Owner: nr
--

ALTER TABLE ONLY public.tags
    ADD CONSTRAINT tags_pkey PRIMARY KEY (id);


--
-- Name: research_topic_sections research_topic_sections_research_topic_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: nr
--

ALTER TABLE ONLY public.research_topic_sections
    ADD CONSTRAINT research_topic_sections_research_topic_id_fkey FOREIGN KEY (research_topic_id) REFERENCES public.research_topics(id) ON DELETE CASCADE;


--
-- Name: research_topic_sections research_topic_sections_section_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: nr
--

ALTER TABLE ONLY public.research_topic_sections
    ADD CONSTRAINT research_topic_sections_section_id_fkey FOREIGN KEY (section_id) REFERENCES public.source_sections(id) ON DELETE CASCADE;


--
-- Name: research_topic_tags research_topic_tags_research_topic_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: nr
--

ALTER TABLE ONLY public.research_topic_tags
    ADD CONSTRAINT research_topic_tags_research_topic_id_fkey FOREIGN KEY (research_topic_id) REFERENCES public.research_topics(id) ON DELETE CASCADE;


--
-- Name: research_topic_tags research_topic_tags_tag_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: nr
--

ALTER TABLE ONLY public.research_topic_tags
    ADD CONSTRAINT research_topic_tags_tag_id_fkey FOREIGN KEY (tag_id) REFERENCES public.tags(id) ON DELETE CASCADE;


--
-- Name: section_tags section_tags_section_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: nr
--

ALTER TABLE ONLY public.section_tags
    ADD CONSTRAINT section_tags_section_id_fkey FOREIGN KEY (section_id) REFERENCES public.source_sections(id) ON DELETE CASCADE;


--
-- Name: section_tags section_tags_tag_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: nr
--

ALTER TABLE ONLY public.section_tags
    ADD CONSTRAINT section_tags_tag_id_fkey FOREIGN KEY (tag_id) REFERENCES public.tags(id) ON DELETE CASCADE;


--
-- Name: source_sections source_sections_document_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: nr
--

ALTER TABLE ONLY public.source_sections
    ADD CONSTRAINT source_sections_document_id_fkey FOREIGN KEY (document_id) REFERENCES public.source_documents(id) ON DELETE CASCADE;


--
-- Name: source_sections source_sections_tag_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: nr
--

ALTER TABLE ONLY public.source_sections
    ADD CONSTRAINT source_sections_tag_id_fkey FOREIGN KEY (tag_id) REFERENCES public.tags(id) ON DELETE SET NULL;


--
-- Name: tag_links tag_links_source_tag_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: nr
--

ALTER TABLE ONLY public.tag_links
    ADD CONSTRAINT tag_links_source_tag_id_fkey FOREIGN KEY (source_tag_id) REFERENCES public.tags(id);


--
-- Name: tag_links tag_links_target_tag_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: nr
--

ALTER TABLE ONLY public.tag_links
    ADD CONSTRAINT tag_links_target_tag_id_fkey FOREIGN KEY (target_tag_id) REFERENCES public.tags(id);


--
-- PostgreSQL database dump complete
--

\unrestrict 51kHp25pDHLUUTf5tkmTciiODhAKYnuQ21mWipIZVhOT2twjj7zeeqz1wOe5z0D

