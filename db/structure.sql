--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: abstracts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE abstracts (
    id integer NOT NULL,
    endnote_citation text,
    abstract text,
    authors text,
    full_authors text,
    is_first_author_investigator boolean DEFAULT false,
    is_last_author_investigator boolean DEFAULT false,
    title text,
    journal_abbreviation character varying(255),
    journal character varying(255),
    volume character varying(255),
    issue character varying(255),
    pages character varying(255),
    year character varying(255),
    publication_date date,
    publication_type character varying(255),
    electronic_publication_date date,
    deposited_date date,
    status character varying(255),
    publication_status character varying(255),
    pubmed character varying(255),
    issn character varying(255),
    isbn character varying(255),
    citation_cnt integer DEFAULT 0,
    citation_last_get_at timestamp without time zone,
    citation_url character varying(255),
    url character varying(255),
    mesh text,
    created_id integer,
    created_ip character varying(255),
    updated_id integer,
    updated_ip character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    is_cancer boolean DEFAULT true NOT NULL,
    pubmedcentral character varying(255),
    vectors tsvector,
    is_valid boolean DEFAULT true NOT NULL,
    reviewed_at timestamp without time zone,
    reviewed_id integer,
    reviewed_ip character varying(255),
    last_reviewed_at timestamp without time zone,
    last_reviewed_id integer,
    last_reviewed_ip character varying(255),
    pubmed_creation_date date,
    doi character varying(255),
    author_affiliations text
);


--
-- Name: abstracts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE abstracts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: abstracts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE abstracts_id_seq OWNED BY abstracts.id;


--
-- Name: investigator_abstracts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE investigator_abstracts (
    id integer NOT NULL,
    abstract_id integer NOT NULL,
    investigator_id integer NOT NULL,
    is_first_author boolean DEFAULT false NOT NULL,
    is_last_author boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    is_valid boolean DEFAULT false NOT NULL,
    reviewed_at timestamp without time zone,
    reviewed_id integer,
    reviewed_ip character varying(255),
    last_reviewed_at timestamp without time zone,
    last_reviewed_id integer,
    last_reviewed_ip character varying(255),
    publication_date date
);


--
-- Name: investigator_abstracts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE investigator_abstracts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: investigator_abstracts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE investigator_abstracts_id_seq OWNED BY investigator_abstracts.id;


--
-- Name: investigator_appointments; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE investigator_appointments (
    id integer NOT NULL,
    organizational_unit_id integer NOT NULL,
    investigator_id integer NOT NULL,
    type character varying(255),
    start_date date,
    end_date date,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    research_summary text
);


--
-- Name: investigator_appointments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE investigator_appointments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: investigator_appointments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE investigator_appointments_id_seq OWNED BY investigator_appointments.id;


--
-- Name: investigator_colleagues; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE investigator_colleagues (
    id integer NOT NULL,
    investigator_id integer,
    colleague_id integer,
    mesh_tags_cnt integer DEFAULT 0,
    mesh_tags_ic double precision DEFAULT 0.0,
    tag_list text,
    publication_cnt integer DEFAULT 0,
    publication_list text,
    in_same_program boolean DEFAULT false,
    proposal_cnt integer DEFAULT 0,
    proposal_list text,
    study_cnt integer DEFAULT 0,
    study_list text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: investigator_colleagues_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE investigator_colleagues_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: investigator_colleagues_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE investigator_colleagues_id_seq OWNED BY investigator_colleagues.id;


--
-- Name: investigator_proposals; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE investigator_proposals (
    id integer NOT NULL,
    role character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    investigator_id integer NOT NULL,
    proposal_id integer NOT NULL,
    percent_effort integer DEFAULT 0,
    is_main_pi boolean DEFAULT false NOT NULL
);


--
-- Name: investigator_proposals_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE investigator_proposals_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: investigator_proposals_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE investigator_proposals_id_seq OWNED BY investigator_proposals.id;


--
-- Name: investigator_studies; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE investigator_studies (
    id integer NOT NULL,
    status character varying(255),
    approval_date date,
    completion_date date,
    role character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    investigator_id integer NOT NULL,
    study_id integer NOT NULL,
    consent_role character varying(255)
);


--
-- Name: investigator_studies_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE investigator_studies_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: investigator_studies_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE investigator_studies_id_seq OWNED BY investigator_studies.id;


--
-- Name: investigators; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE investigators (
    id integer NOT NULL,
    username character varying(255) NOT NULL,
    last_name character varying(255) NOT NULL,
    first_name character varying(255) NOT NULL,
    middle_name character varying(255),
    email character varying(255),
    degrees character varying(255),
    suffix character varying(255),
    employee_id integer,
    title character varying(255),
    home_department_id integer,
    campus character varying(255),
    appointment_type character varying(255),
    appointment_track character varying(255),
    appointment_basis character varying(255),
    pubmed_search_name character varying(255),
    pubmed_limit_to_institution boolean DEFAULT false,
    num_first_pubs_last_five_years integer DEFAULT 0,
    num_last_pubs_last_five_years integer DEFAULT 0,
    total_publications_last_five_years integer DEFAULT 0,
    num_intraunit_collaborators_last_five_years integer DEFAULT 0,
    num_extraunit_collaborators_last_five_years integer DEFAULT 0,
    num_first_pubs integer DEFAULT 0,
    num_last_pubs integer DEFAULT 0,
    total_publications integer DEFAULT 0,
    num_intraunit_collaborators integer DEFAULT 0,
    num_extraunit_collaborators integer DEFAULT 0,
    last_pubmed_search date,
    mailcode character varying(255),
    address1 text,
    address2 character varying(255),
    city character varying(255),
    state character varying(255),
    postal_code character varying(255),
    country character varying(255),
    business_phone character varying(255),
    home_phone character varying(255),
    lab_phone character varying(255),
    fax character varying(255),
    pager character varying(255),
    ssn character varying(9),
    sex character varying(1),
    birth_date date,
    nu_start_date date,
    start_date date,
    end_date date,
    weekly_hours_min integer DEFAULT 35,
    last_successful_login timestamp without time zone,
    last_login_failure timestamp without time zone,
    consecutive_login_failures integer DEFAULT 0,
    password character varying(255),
    password_changed_at timestamp without time zone,
    password_changed_id integer,
    password_changed_ip character varying(255),
    created_id integer,
    created_ip character varying(255),
    updated_id integer,
    updated_ip character varying(255),
    deleted_at timestamp without time zone,
    deleted_id integer,
    deleted_ip character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    faculty_keywords text,
    faculty_research_summary text,
    faculty_interests text,
    vectors tsvector,
    total_studies integer DEFAULT 0 NOT NULL,
    total_studies_collaborators integer DEFAULT 0 NOT NULL,
    total_pi_studies integer DEFAULT 0 NOT NULL,
    total_pi_studies_collaborators integer DEFAULT 0 NOT NULL,
    total_awards integer DEFAULT 0 NOT NULL,
    total_awards_collaborators integer DEFAULT 0 NOT NULL,
    total_pi_awards integer DEFAULT 0 NOT NULL,
    total_pi_awards_collaborators integer DEFAULT 0 NOT NULL,
    home_department_name character varying(255),
    era_commons_name character varying(255)
);


--
-- Name: investigators_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE investigators_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: investigators_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE investigators_id_seq OWNED BY investigators.id;


--
-- Name: journals; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE journals (
    id integer NOT NULL,
    journal_name character varying(255),
    journal_abbreviation character varying(255) NOT NULL,
    jcr_journal_abbreviation character varying(255),
    issn character varying(255),
    score_year integer,
    total_cites integer,
    impact_factor double precision,
    impact_factor_five_year double precision,
    immediacy_index double precision,
    total_articles integer,
    eigenfactor_score double precision,
    article_influence_score double precision,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    include_as_high_impact boolean DEFAULT false NOT NULL
);


--
-- Name: journals_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE journals_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: journals_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE journals_id_seq OWNED BY journals.id;


--
-- Name: load_dates; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE load_dates (
    id integer NOT NULL,
    load_date timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: load_dates_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE load_dates_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: load_dates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE load_dates_id_seq OWNED BY load_dates.id;


--
-- Name: logs; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE logs (
    id integer NOT NULL,
    activity character varying(255),
    investigator_id integer,
    program_id integer,
    controller_name character varying(255),
    action_name character varying(255),
    params text,
    created_ip character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: logs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE logs_id_seq OWNED BY logs.id;


--
-- Name: organization_abstracts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE organization_abstracts (
    id integer NOT NULL,
    organizational_unit_id integer NOT NULL,
    abstract_id integer NOT NULL,
    start_date date,
    end_date date,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: organization_abstracts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE organization_abstracts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: organization_abstracts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE organization_abstracts_id_seq OWNED BY organization_abstracts.id;


--
-- Name: organizational_units; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE organizational_units (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    search_name character varying(255),
    abbreviation character varying(255),
    campus character varying(255),
    organization_url character varying(255),
    type character varying(255) NOT NULL,
    organization_classification character varying(255),
    organization_phone character varying(255),
    department_id integer DEFAULT 0 NOT NULL,
    division_id integer DEFAULT 0,
    member_count integer DEFAULT 0,
    appointment_count integer DEFAULT 0,
    lft integer,
    rgt integer,
    children_count integer DEFAULT 0,
    sort_order integer DEFAULT 1,
    parent_id integer,
    depth integer DEFAULT 0,
    start_date date,
    end_date date,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: organizational_units_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE organizational_units_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: organizational_units_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE organizational_units_id_seq OWNED BY organizational_units.id;


--
-- Name: proposals; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE proposals (
    id integer NOT NULL,
    sponsor_award_number character varying(255),
    sponsor_code character varying(255),
    sponsor_name character varying(255),
    institution_award_number character varying(255),
    title character varying(255),
    abstract text,
    keywords text,
    agency character varying(255),
    submission_date date,
    project_start_date date,
    project_end_date date,
    is_awarded boolean DEFAULT true,
    award_category character varying(255),
    award_mechanism character varying(255),
    award_type character varying(255),
    url character varying(255),
    created_id integer,
    created_ip character varying(255),
    updated_id integer,
    updated_ip character varying(255),
    deleted_at timestamp without time zone,
    deleted_id integer,
    deleted_ip character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    award_start_date date,
    award_end_date date,
    direct_amount integer,
    indirect_amount integer,
    total_amount integer,
    sponsor_type_name character varying(255),
    sponsor_type_code character varying(255),
    original_sponsor_name character varying(255),
    original_sponsor_code character varying(255),
    pi_employee_id character varying(255),
    parent_institution_award_number character varying(255),
    merged boolean DEFAULT false
);


--
-- Name: proposals_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE proposals_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: proposals_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE proposals_id_seq OWNED BY proposals.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: studies; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE studies (
    id integer NOT NULL,
    title text,
    abstract text,
    sponsor character varying(255),
    nct_id character varying(255),
    accrual_goal integer,
    approved_date date,
    closed_date date,
    completed_date date,
    status character varying(255),
    url character varying(255),
    created_id integer,
    created_ip character varying(255),
    updated_id integer,
    updated_ip character varying(255),
    deleted_at timestamp without time zone,
    deleted_id integer,
    deleted_ip character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    enotis_study_id integer,
    irb_study_number character varying(255),
    research_type character varying(255),
    review_type character varying(255),
    proposal_id integer,
    is_clinical_trial boolean DEFAULT false NOT NULL,
    inclusion_criteria text,
    exclusion_criteria text,
    has_medical_services boolean DEFAULT false NOT NULL,
    had_import_errors boolean DEFAULT false,
    next_review_date date
);


--
-- Name: studies_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE studies_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: studies_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE studies_id_seq OWNED BY studies.id;


--
-- Name: taggings; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE taggings (
    id integer NOT NULL,
    tag_id integer,
    taggable_id integer,
    information_content double precision DEFAULT 0,
    taggable_type character varying(255),
    created_at timestamp without time zone
);


--
-- Name: taggings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE taggings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: taggings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE taggings_id_seq OWNED BY taggings.id;


--
-- Name: tags; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE tags (
    id integer NOT NULL,
    name character varying(255)
);


--
-- Name: tags_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE tags_id_seq OWNED BY tags.id;


--
-- Name: word_frequencies; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE word_frequencies (
    id integer NOT NULL,
    frequency integer,
    word character varying(255),
    the_type character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: word_frequencies_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE word_frequencies_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: word_frequencies_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE word_frequencies_id_seq OWNED BY word_frequencies.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY abstracts ALTER COLUMN id SET DEFAULT nextval('abstracts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY investigator_abstracts ALTER COLUMN id SET DEFAULT nextval('investigator_abstracts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY investigator_appointments ALTER COLUMN id SET DEFAULT nextval('investigator_appointments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY investigator_colleagues ALTER COLUMN id SET DEFAULT nextval('investigator_colleagues_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY investigator_proposals ALTER COLUMN id SET DEFAULT nextval('investigator_proposals_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY investigator_studies ALTER COLUMN id SET DEFAULT nextval('investigator_studies_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY investigators ALTER COLUMN id SET DEFAULT nextval('investigators_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY journals ALTER COLUMN id SET DEFAULT nextval('journals_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY load_dates ALTER COLUMN id SET DEFAULT nextval('load_dates_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY logs ALTER COLUMN id SET DEFAULT nextval('logs_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY organization_abstracts ALTER COLUMN id SET DEFAULT nextval('organization_abstracts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY organizational_units ALTER COLUMN id SET DEFAULT nextval('organizational_units_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY proposals ALTER COLUMN id SET DEFAULT nextval('proposals_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY studies ALTER COLUMN id SET DEFAULT nextval('studies_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY taggings ALTER COLUMN id SET DEFAULT nextval('taggings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY tags ALTER COLUMN id SET DEFAULT nextval('tags_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY word_frequencies ALTER COLUMN id SET DEFAULT nextval('word_frequencies_id_seq'::regclass);


--
-- Name: abstracts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY abstracts
    ADD CONSTRAINT abstracts_pkey PRIMARY KEY (id);


--
-- Name: investigator_abstracts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY investigator_abstracts
    ADD CONSTRAINT investigator_abstracts_pkey PRIMARY KEY (id);


--
-- Name: investigator_appointments_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY investigator_appointments
    ADD CONSTRAINT investigator_appointments_pkey PRIMARY KEY (id);


--
-- Name: investigator_colleagues_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY investigator_colleagues
    ADD CONSTRAINT investigator_colleagues_pkey PRIMARY KEY (id);


--
-- Name: investigator_proposals_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY investigator_proposals
    ADD CONSTRAINT investigator_proposals_pkey PRIMARY KEY (id);


--
-- Name: investigator_studies_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY investigator_studies
    ADD CONSTRAINT investigator_studies_pkey PRIMARY KEY (id);


--
-- Name: investigators_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY investigators
    ADD CONSTRAINT investigators_pkey PRIMARY KEY (id);


--
-- Name: journals_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY journals
    ADD CONSTRAINT journals_pkey PRIMARY KEY (id);


--
-- Name: load_dates_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY load_dates
    ADD CONSTRAINT load_dates_pkey PRIMARY KEY (id);


--
-- Name: logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY logs
    ADD CONSTRAINT logs_pkey PRIMARY KEY (id);


--
-- Name: organization_abstracts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY organization_abstracts
    ADD CONSTRAINT organization_abstracts_pkey PRIMARY KEY (id);


--
-- Name: organizational_units_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY organizational_units
    ADD CONSTRAINT organizational_units_pkey PRIMARY KEY (id);


--
-- Name: proposals_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY proposals
    ADD CONSTRAINT proposals_pkey PRIMARY KEY (id);


--
-- Name: studies_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY studies
    ADD CONSTRAINT studies_pkey PRIMARY KEY (id);


--
-- Name: taggings_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY taggings
    ADD CONSTRAINT taggings_pkey PRIMARY KEY (id);


--
-- Name: tags_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY tags
    ADD CONSTRAINT tags_pkey PRIMARY KEY (id);


--
-- Name: word_frequencies_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY word_frequencies
    ADD CONSTRAINT word_frequencies_pkey PRIMARY KEY (id);


--
-- Name: abstracts_fts_vectors_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX abstracts_fts_vectors_index ON abstracts USING gist (vectors);


--
-- Name: by_asbtract_investigator_unique; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX by_asbtract_investigator_unique ON investigator_abstracts USING btree (abstract_id, investigator_id);


--
-- Name: by_colleague_investigator; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX by_colleague_investigator ON investigator_colleagues USING btree (colleague_id, investigator_id);


--
-- Name: by_colleague_mesh_ic; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX by_colleague_mesh_ic ON investigator_colleagues USING btree (colleague_id, investigator_id, mesh_tags_ic);


--
-- Name: by_colleague_pubs; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX by_colleague_pubs ON investigator_colleagues USING btree (colleague_id, investigator_id, publication_cnt);


--
-- Name: by_era_commons_name_unique; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX by_era_commons_name_unique ON investigators USING btree (era_commons_name);


--
-- Name: by_keywords_summary_interests; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX by_keywords_summary_interests ON investigators USING btree (faculty_keywords, faculty_interests);


--
-- Name: by_pubmed_doi_unique; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX by_pubmed_doi_unique ON abstracts USING btree (pubmed, doi);


--
-- Name: by_unit_abstract_unique; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX by_unit_abstract_unique ON organization_abstracts USING btree (organizational_unit_id, abstract_id);


--
-- Name: by_unit_investigator_unique; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX by_unit_investigator_unique ON investigator_appointments USING btree (organizational_unit_id, investigator_id, type);


--
-- Name: by_word; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX by_word ON word_frequencies USING btree (word);


--
-- Name: by_word_type_unique; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX by_word_type_unique ON word_frequencies USING btree (word, the_type);


--
-- Name: index_investigators_on_username; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_investigators_on_username ON investigators USING btree (username);


--
-- Name: index_journals_on_journal_abbreviation; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_journals_on_journal_abbreviation ON journals USING btree (journal_abbreviation);


--
-- Name: index_load_dates_on_load_date; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_load_dates_on_load_date ON load_dates USING btree (load_date);


--
-- Name: index_organizational_units_on_department_id_and_division_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_organizational_units_on_department_id_and_division_id ON organizational_units USING btree (department_id, division_id);


--
-- Name: index_taggings_on_tag_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_taggings_on_tag_id ON taggings USING btree (tag_id);


--
-- Name: index_taggings_on_taggable_id_and_taggable_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_taggings_on_taggable_id_and_taggable_type ON taggings USING btree (taggable_id, taggable_type);


--
-- Name: investigators_fts_vectors_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX investigators_fts_vectors_index ON investigators USING gist (vectors);


--
-- Name: mesh_tags_ic; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX mesh_tags_ic ON investigator_colleagues USING btree (mesh_tags_ic);


--
-- Name: study_by_enotis_study_id_uq; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX study_by_enotis_study_id_uq ON studies USING btree (enotis_study_id);


--
-- Name: study_by_irb_study_number_uq; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX study_by_irb_study_number_uq ON studies USING btree (irb_study_number);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- Name: fk_abstracts_to_investigator_abstracts; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY investigator_abstracts
    ADD CONSTRAINT fk_abstracts_to_investigator_abstracts FOREIGN KEY (abstract_id) REFERENCES abstracts(id);


--
-- Name: fk_abstracts_to_organization_abstracts; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY organization_abstracts
    ADD CONSTRAINT fk_abstracts_to_organization_abstracts FOREIGN KEY (abstract_id) REFERENCES abstracts(id);


--
-- Name: fk_investigators_to_investigator_abstracts; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY investigator_abstracts
    ADD CONSTRAINT fk_investigators_to_investigator_abstracts FOREIGN KEY (investigator_id) REFERENCES investigators(id);


--
-- Name: fk_investigators_to_investigator_appointments; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY investigator_appointments
    ADD CONSTRAINT fk_investigators_to_investigator_appointments FOREIGN KEY (investigator_id) REFERENCES investigators(id);


--
-- Name: fk_investigators_to_investigator_colleagues; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY investigator_colleagues
    ADD CONSTRAINT fk_investigators_to_investigator_colleagues FOREIGN KEY (investigator_id) REFERENCES investigators(id);


--
-- Name: fk_investigators_to_investigator_colleagues_colleague_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY investigator_colleagues
    ADD CONSTRAINT fk_investigators_to_investigator_colleagues_colleague_id FOREIGN KEY (colleague_id) REFERENCES investigators(id);


--
-- Name: fk_investigators_to_investigator_proposals; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY investigator_proposals
    ADD CONSTRAINT fk_investigators_to_investigator_proposals FOREIGN KEY (investigator_id) REFERENCES investigators(id);


--
-- Name: fk_investigators_to_investigator_studies; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY investigator_studies
    ADD CONSTRAINT fk_investigators_to_investigator_studies FOREIGN KEY (investigator_id) REFERENCES investigators(id);


--
-- Name: fk_organizational_units_to_investigator_appointments; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY investigator_appointments
    ADD CONSTRAINT fk_organizational_units_to_investigator_appointments FOREIGN KEY (organizational_unit_id) REFERENCES organizational_units(id);


--
-- Name: fk_organizational_units_to_organization_abstracts; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY organization_abstracts
    ADD CONSTRAINT fk_organizational_units_to_organization_abstracts FOREIGN KEY (organizational_unit_id) REFERENCES organizational_units(id);


--
-- Name: fk_proposals_to_investigator_proposals; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY investigator_proposals
    ADD CONSTRAINT fk_proposals_to_investigator_proposals FOREIGN KEY (proposal_id) REFERENCES proposals(id);


--
-- Name: fk_proposals_to_studies; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY studies
    ADD CONSTRAINT fk_proposals_to_studies FOREIGN KEY (proposal_id) REFERENCES proposals(id);


--
-- Name: fk_studies_to_investigator_studies; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY investigator_studies
    ADD CONSTRAINT fk_studies_to_investigator_studies FOREIGN KEY (study_id) REFERENCES studies(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user",public;

INSERT INTO schema_migrations (version) VALUES ('20080908');

INSERT INTO schema_migrations (version) VALUES ('20080909');

INSERT INTO schema_migrations (version) VALUES ('20080910');

INSERT INTO schema_migrations (version) VALUES ('20080911');

INSERT INTO schema_migrations (version) VALUES ('20080912');

INSERT INTO schema_migrations (version) VALUES ('20080914');

INSERT INTO schema_migrations (version) VALUES ('20080915');

INSERT INTO schema_migrations (version) VALUES ('20080916');

INSERT INTO schema_migrations (version) VALUES ('20090225213932');

INSERT INTO schema_migrations (version) VALUES ('20090225213947');

INSERT INTO schema_migrations (version) VALUES ('20090225213959');

INSERT INTO schema_migrations (version) VALUES ('20090225214009');

INSERT INTO schema_migrations (version) VALUES ('20090225214105');

INSERT INTO schema_migrations (version) VALUES ('20090708162318');

INSERT INTO schema_migrations (version) VALUES ('20090714021145');

INSERT INTO schema_migrations (version) VALUES ('20100901042417');

INSERT INTO schema_migrations (version) VALUES ('20101003170716');

INSERT INTO schema_migrations (version) VALUES ('20101206225809');

INSERT INTO schema_migrations (version) VALUES ('20110203133338');

INSERT INTO schema_migrations (version) VALUES ('20110205035911');

INSERT INTO schema_migrations (version) VALUES ('20110404215324');

INSERT INTO schema_migrations (version) VALUES ('20110417160106');

INSERT INTO schema_migrations (version) VALUES ('20110804191522');

INSERT INTO schema_migrations (version) VALUES ('20110818121950');

INSERT INTO schema_migrations (version) VALUES ('20110913212242');

INSERT INTO schema_migrations (version) VALUES ('20110922214737');

INSERT INTO schema_migrations (version) VALUES ('20120117140721');

INSERT INTO schema_migrations (version) VALUES ('20120426214617');

INSERT INTO schema_migrations (version) VALUES ('20120826035935');

INSERT INTO schema_migrations (version) VALUES ('20121214042329');

INSERT INTO schema_migrations (version) VALUES ('20130327155943');

INSERT INTO schema_migrations (version) VALUES ('20131121210426');

INSERT INTO schema_migrations (version) VALUES ('20140319212053');