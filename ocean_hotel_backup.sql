--
-- PostgreSQL database dump
--

-- Dumped from database version 17.4
-- Dumped by pg_dump version 17.4

-- Started on 2025-07-27 15:08:38

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 2 (class 3079 OID 16463)
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- TOC entry 5078 (class 0 OID 0)
-- Dependencies: 2
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- TOC entry 292 (class 1255 OID 16764)
-- Name: update_timestamp(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_timestamp() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  NEW.updated_at = NOW(); -- Cập nhật thời gian hiện tại vào cột updated_at
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_timestamp() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 218 (class 1259 OID 16500)
-- Name: admins; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.admins (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    email character varying(255) NOT NULL,
    password character varying(255) NOT NULL,
    phone character varying(20),
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.admins OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 16506)
-- Name: admins_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.admins_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.admins_id_seq OWNER TO postgres;

--
-- TOC entry 5079 (class 0 OID 0)
-- Dependencies: 219
-- Name: admins_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.admins_id_seq OWNED BY public.admins.id;


--
-- TOC entry 220 (class 1259 OID 16507)
-- Name: bookings; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.bookings (
    id integer NOT NULL,
    user_id integer NOT NULL,
    room_id integer NOT NULL,
    check_in date NOT NULL,
    check_out date NOT NULL,
    total_price numeric(10,2) NOT NULL,
    status character varying(20) DEFAULT 'pending'::character varying,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    deleted_at timestamp without time zone,
    discount_code character varying(255),
    discount_percent numeric(5,2),
    CONSTRAINT bookings_status_check CHECK (((status)::text = ANY ((ARRAY['pending'::character varying, 'confirmed'::character varying, 'canceled'::character varying, 'done'::character varying])::text[])))
);


ALTER TABLE public.bookings OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 16513)
-- Name: bookings_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.bookings_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.bookings_id_seq OWNER TO postgres;

--
-- TOC entry 5080 (class 0 OID 0)
-- Dependencies: 221
-- Name: bookings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.bookings_id_seq OWNED BY public.bookings.id;


--
-- TOC entry 222 (class 1259 OID 16514)
-- Name: contacts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.contacts (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    email character varying(255),
    phone character varying(20),
    subject character varying(255),
    message text NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    replied boolean DEFAULT false,
    deleted_at timestamp without time zone
);


ALTER TABLE public.contacts OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 16520)
-- Name: contacts_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.contacts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.contacts_id_seq OWNER TO postgres;

--
-- TOC entry 5081 (class 0 OID 0)
-- Dependencies: 223
-- Name: contacts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.contacts_id_seq OWNED BY public.contacts.id;


--
-- TOC entry 224 (class 1259 OID 16521)
-- Name: conversations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.conversations (
    id integer NOT NULL,
    user_id integer,
    start_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    end_time timestamp without time zone,
    status character varying(20) DEFAULT 'active'::character varying,
    agent_id integer
);


ALTER TABLE public.conversations OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 16526)
-- Name: conversations_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.conversations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.conversations_id_seq OWNER TO postgres;

--
-- TOC entry 5082 (class 0 OID 0)
-- Dependencies: 225
-- Name: conversations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.conversations_id_seq OWNED BY public.conversations.id;


--
-- TOC entry 226 (class 1259 OID 16527)
-- Name: discounts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.discounts (
    id integer NOT NULL,
    code character varying(50) NOT NULL,
    description text,
    discount_type character varying(20) NOT NULL,
    discount_value numeric(10,2) NOT NULL,
    start_date timestamp without time zone NOT NULL,
    end_date timestamp without time zone NOT NULL,
    status character varying(20) DEFAULT 'active'::character varying,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    deleted_at timestamp without time zone
);


ALTER TABLE public.discounts OWNER TO postgres;

--
-- TOC entry 227 (class 1259 OID 16535)
-- Name: discounts_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.discounts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.discounts_id_seq OWNER TO postgres;

--
-- TOC entry 5083 (class 0 OID 0)
-- Dependencies: 227
-- Name: discounts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.discounts_id_seq OWNED BY public.discounts.id;


--
-- TOC entry 228 (class 1259 OID 16541)
-- Name: faq; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.faq (
    id integer NOT NULL,
    question text NOT NULL,
    answer text NOT NULL,
    category character varying(100),
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.faq OWNER TO postgres;

--
-- TOC entry 229 (class 1259 OID 16547)
-- Name: faq_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.faq_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.faq_id_seq OWNER TO postgres;

--
-- TOC entry 5084 (class 0 OID 0)
-- Dependencies: 229
-- Name: faq_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.faq_id_seq OWNED BY public.faq.id;


--
-- TOC entry 255 (class 1259 OID 25019)
-- Name: hotel_info; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.hotel_info (
    id integer NOT NULL,
    key character varying(100) NOT NULL,
    value text NOT NULL
);


ALTER TABLE public.hotel_info OWNER TO postgres;

--
-- TOC entry 254 (class 1259 OID 25018)
-- Name: hotel_info_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.hotel_info_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.hotel_info_id_seq OWNER TO postgres;

--
-- TOC entry 5085 (class 0 OID 0)
-- Dependencies: 254
-- Name: hotel_info_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.hotel_info_id_seq OWNED BY public.hotel_info.id;


--
-- TOC entry 230 (class 1259 OID 16548)
-- Name: images; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.images (
    id integer NOT NULL,
    object_type character varying(50) NOT NULL,
    object_id integer NOT NULL,
    image_url text NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_object_type CHECK (((object_type)::text = ANY (ARRAY[('room'::character varying)::text, ('service'::character varying)::text])))
);


ALTER TABLE public.images OWNER TO postgres;

--
-- TOC entry 231 (class 1259 OID 16555)
-- Name: images_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.images_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.images_id_seq OWNER TO postgres;

--
-- TOC entry 5086 (class 0 OID 0)
-- Dependencies: 231
-- Name: images_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.images_id_seq OWNED BY public.images.id;


--
-- TOC entry 232 (class 1259 OID 16556)
-- Name: invoice_items; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.invoice_items (
    id integer NOT NULL,
    invoice_id integer NOT NULL,
    description character varying(255) NOT NULL,
    amount numeric(10,2) NOT NULL,
    quantity integer DEFAULT 1,
    total_amount numeric(10,2) NOT NULL
);


ALTER TABLE public.invoice_items OWNER TO postgres;

--
-- TOC entry 233 (class 1259 OID 16560)
-- Name: invoice_items_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.invoice_items_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.invoice_items_id_seq OWNER TO postgres;

--
-- TOC entry 5087 (class 0 OID 0)
-- Dependencies: 233
-- Name: invoice_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.invoice_items_id_seq OWNED BY public.invoice_items.id;


--
-- TOC entry 234 (class 1259 OID 16561)
-- Name: invoices; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.invoices (
    id integer NOT NULL,
    booking_id integer NOT NULL,
    total_amount numeric(10,2) NOT NULL,
    status character varying(20) DEFAULT 'unpaid'::character varying,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    deleted_at timestamp without time zone,
    CONSTRAINT invoices_status_check CHECK (((status)::text = ANY (ARRAY[('paid'::character varying)::text, ('unpaid'::character varying)::text])))
);


ALTER TABLE public.invoices OWNER TO postgres;

--
-- TOC entry 235 (class 1259 OID 16567)
-- Name: invoices_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.invoices_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.invoices_id_seq OWNER TO postgres;

--
-- TOC entry 5088 (class 0 OID 0)
-- Dependencies: 235
-- Name: invoices_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.invoices_id_seq OWNED BY public.invoices.id;


--
-- TOC entry 236 (class 1259 OID 16568)
-- Name: messages; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.messages (
    id integer NOT NULL,
    conversation_id integer NOT NULL,
    sender character varying(20) NOT NULL,
    message text NOT NULL,
    "timestamp" timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    deleted_at timestamp without time zone,
    CONSTRAINT messages_sender_check CHECK (((sender)::text = ANY (ARRAY[('user'::character varying)::text, ('bot'::character varying)::text, ('agent'::character varying)::text])))
);


ALTER TABLE public.messages OWNER TO postgres;

--
-- TOC entry 237 (class 1259 OID 16575)
-- Name: messages_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.messages_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.messages_id_seq OWNER TO postgres;

--
-- TOC entry 5089 (class 0 OID 0)
-- Dependencies: 237
-- Name: messages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.messages_id_seq OWNED BY public.messages.id;


--
-- TOC entry 251 (class 1259 OID 16767)
-- Name: migrations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.migrations (
    id integer NOT NULL,
    migration character varying(255) NOT NULL,
    batch integer NOT NULL
);


ALTER TABLE public.migrations OWNER TO postgres;

--
-- TOC entry 250 (class 1259 OID 16766)
-- Name: migrations_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.migrations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.migrations_id_seq OWNER TO postgres;

--
-- TOC entry 5090 (class 0 OID 0)
-- Dependencies: 250
-- Name: migrations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.migrations_id_seq OWNED BY public.migrations.id;


--
-- TOC entry 238 (class 1259 OID 16576)
-- Name: payments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.payments (
    id integer NOT NULL,
    booking_id integer NOT NULL,
    amount numeric(10,2) NOT NULL,
    payment_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    method character varying(20) NOT NULL,
    status character varying(20) DEFAULT 'unpaid'::character varying,
    momo_order_id character varying(50),
    deleted_at timestamp without time zone,
    CONSTRAINT payments_method_check CHECK (((method)::text = ANY ((ARRAY['wallet'::character varying, 'atm'::character varying, 'qr'::character varying])::text[]))),
    CONSTRAINT payments_status_check CHECK (((status)::text = ANY (ARRAY[('paid'::character varying)::text, ('unpaid'::character varying)::text])))
);


ALTER TABLE public.payments OWNER TO postgres;

--
-- TOC entry 239 (class 1259 OID 16583)
-- Name: payments_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.payments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.payments_id_seq OWNER TO postgres;

--
-- TOC entry 5091 (class 0 OID 0)
-- Dependencies: 239
-- Name: payments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.payments_id_seq OWNED BY public.payments.id;


--
-- TOC entry 253 (class 1259 OID 16793)
-- Name: personal_access_tokens; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.personal_access_tokens (
    id bigint NOT NULL,
    tokenable_type character varying(255) NOT NULL,
    tokenable_id bigint NOT NULL,
    name character varying(255) NOT NULL,
    token character varying(64) NOT NULL,
    abilities text,
    last_used_at timestamp(0) without time zone,
    expires_at timestamp(0) without time zone,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


ALTER TABLE public.personal_access_tokens OWNER TO postgres;

--
-- TOC entry 252 (class 1259 OID 16792)
-- Name: personal_access_tokens_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.personal_access_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.personal_access_tokens_id_seq OWNER TO postgres;

--
-- TOC entry 5092 (class 0 OID 0)
-- Dependencies: 252
-- Name: personal_access_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.personal_access_tokens_id_seq OWNED BY public.personal_access_tokens.id;


--
-- TOC entry 240 (class 1259 OID 16584)
-- Name: reviews; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.reviews (
    id integer NOT NULL,
    user_id integer NOT NULL,
    room_id integer NOT NULL,
    rating integer,
    comment text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    booking_id bigint,
    CONSTRAINT reviews_rating_check CHECK (((rating >= 1) AND (rating <= 5)))
);


ALTER TABLE public.reviews OWNER TO postgres;

--
-- TOC entry 241 (class 1259 OID 16591)
-- Name: reviews_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.reviews_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.reviews_id_seq OWNER TO postgres;

--
-- TOC entry 5093 (class 0 OID 0)
-- Dependencies: 241
-- Name: reviews_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.reviews_id_seq OWNED BY public.reviews.id;


--
-- TOC entry 242 (class 1259 OID 16592)
-- Name: rooms; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.rooms (
    id integer NOT NULL,
    room_number character varying(10) NOT NULL,
    room_type character varying(50) NOT NULL,
    price numeric(10,2) NOT NULL,
    status character varying(20) DEFAULT 'available'::character varying,
    description text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    deleted_at timestamp without time zone,
    capacity integer DEFAULT 2 NOT NULL,
    CONSTRAINT rooms_status_check CHECK (((status)::text = ANY (ARRAY[('available'::character varying)::text, ('booked'::character varying)::text, ('maintenance'::character varying)::text])))
);


ALTER TABLE public.rooms OWNER TO postgres;

--
-- TOC entry 243 (class 1259 OID 16600)
-- Name: rooms_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.rooms_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.rooms_id_seq OWNER TO postgres;

--
-- TOC entry 5094 (class 0 OID 0)
-- Dependencies: 243
-- Name: rooms_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.rooms_id_seq OWNED BY public.rooms.id;


--
-- TOC entry 244 (class 1259 OID 16601)
-- Name: service_orders; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.service_orders (
    id integer NOT NULL,
    booking_id integer NOT NULL,
    service_id integer NOT NULL,
    quantity integer DEFAULT 1 NOT NULL,
    total_price numeric(10,2) NOT NULL,
    order_date date DEFAULT CURRENT_DATE,
    deleted_at timestamp without time zone
);


ALTER TABLE public.service_orders OWNER TO postgres;

--
-- TOC entry 245 (class 1259 OID 16606)
-- Name: service_orders_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.service_orders_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.service_orders_id_seq OWNER TO postgres;

--
-- TOC entry 5095 (class 0 OID 0)
-- Dependencies: 245
-- Name: service_orders_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.service_orders_id_seq OWNED BY public.service_orders.id;


--
-- TOC entry 246 (class 1259 OID 16607)
-- Name: services; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.services (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    price numeric(10,2) NOT NULL,
    description text,
    deleted_at timestamp without time zone
);


ALTER TABLE public.services OWNER TO postgres;

--
-- TOC entry 247 (class 1259 OID 16612)
-- Name: services_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.services_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.services_id_seq OWNER TO postgres;

--
-- TOC entry 5096 (class 0 OID 0)
-- Dependencies: 247
-- Name: services_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.services_id_seq OWNED BY public.services.id;


--
-- TOC entry 248 (class 1259 OID 16613)
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    email character varying(255) NOT NULL,
    password character varying(255) NOT NULL,
    phone character varying(20),
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone,
    deleted_at timestamp without time zone
);


ALTER TABLE public.users OWNER TO postgres;

--
-- TOC entry 249 (class 1259 OID 16619)
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_id_seq OWNER TO postgres;

--
-- TOC entry 5097 (class 0 OID 0)
-- Dependencies: 249
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- TOC entry 4769 (class 2604 OID 16620)
-- Name: admins id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.admins ALTER COLUMN id SET DEFAULT nextval('public.admins_id_seq'::regclass);


--
-- TOC entry 4771 (class 2604 OID 16621)
-- Name: bookings id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bookings ALTER COLUMN id SET DEFAULT nextval('public.bookings_id_seq'::regclass);


--
-- TOC entry 4774 (class 2604 OID 16622)
-- Name: contacts id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.contacts ALTER COLUMN id SET DEFAULT nextval('public.contacts_id_seq'::regclass);


--
-- TOC entry 4777 (class 2604 OID 16623)
-- Name: conversations id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.conversations ALTER COLUMN id SET DEFAULT nextval('public.conversations_id_seq'::regclass);


--
-- TOC entry 4780 (class 2604 OID 16624)
-- Name: discounts id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.discounts ALTER COLUMN id SET DEFAULT nextval('public.discounts_id_seq'::regclass);


--
-- TOC entry 4784 (class 2604 OID 16626)
-- Name: faq id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.faq ALTER COLUMN id SET DEFAULT nextval('public.faq_id_seq'::regclass);


--
-- TOC entry 4812 (class 2604 OID 25022)
-- Name: hotel_info id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hotel_info ALTER COLUMN id SET DEFAULT nextval('public.hotel_info_id_seq'::regclass);


--
-- TOC entry 4786 (class 2604 OID 16627)
-- Name: images id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.images ALTER COLUMN id SET DEFAULT nextval('public.images_id_seq'::regclass);


--
-- TOC entry 4788 (class 2604 OID 16628)
-- Name: invoice_items id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.invoice_items ALTER COLUMN id SET DEFAULT nextval('public.invoice_items_id_seq'::regclass);


--
-- TOC entry 4790 (class 2604 OID 16629)
-- Name: invoices id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.invoices ALTER COLUMN id SET DEFAULT nextval('public.invoices_id_seq'::regclass);


--
-- TOC entry 4793 (class 2604 OID 16630)
-- Name: messages id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.messages ALTER COLUMN id SET DEFAULT nextval('public.messages_id_seq'::regclass);


--
-- TOC entry 4810 (class 2604 OID 16770)
-- Name: migrations id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migrations ALTER COLUMN id SET DEFAULT nextval('public.migrations_id_seq'::regclass);


--
-- TOC entry 4795 (class 2604 OID 16631)
-- Name: payments id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payments ALTER COLUMN id SET DEFAULT nextval('public.payments_id_seq'::regclass);


--
-- TOC entry 4811 (class 2604 OID 16796)
-- Name: personal_access_tokens id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.personal_access_tokens ALTER COLUMN id SET DEFAULT nextval('public.personal_access_tokens_id_seq'::regclass);


--
-- TOC entry 4798 (class 2604 OID 16632)
-- Name: reviews id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reviews ALTER COLUMN id SET DEFAULT nextval('public.reviews_id_seq'::regclass);


--
-- TOC entry 4800 (class 2604 OID 16633)
-- Name: rooms id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rooms ALTER COLUMN id SET DEFAULT nextval('public.rooms_id_seq'::regclass);


--
-- TOC entry 4804 (class 2604 OID 16634)
-- Name: service_orders id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.service_orders ALTER COLUMN id SET DEFAULT nextval('public.service_orders_id_seq'::regclass);


--
-- TOC entry 4807 (class 2604 OID 16635)
-- Name: services id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.services ALTER COLUMN id SET DEFAULT nextval('public.services_id_seq'::regclass);


--
-- TOC entry 4808 (class 2604 OID 16636)
-- Name: users id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- TOC entry 5035 (class 0 OID 16500)
-- Dependencies: 218
-- Data for Name: admins; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.admins (id, name, email, password, phone, created_at) FROM stdin;
1	Admin1	admin1@example.com	$2y$12$aIWQ1o.yuQYBiewVP0Nmp.OJjxKvV9Fn23HH87AdMw1KXwJhPPWh.	\N	2025-04-05 01:51:15.76799
2	Admin2	admin2@example.com	$2a$06$YkTL7K0cCehEQiTjlkd4LOvkiw90imdKYecYMj9ZuRUZmKBfmkRG.	\N	2025-04-05 01:51:43.321273
3	Admin3	admin3@example.com	$2a$06$eIKBh9JcWJDlIx9lZcq27uE/Xt5VM4j46I58wEv5acraMGYdH8P2u	\N	2025-04-05 01:51:54.131706
4	Admin4	admin4@example.com	12345	\N	2025-07-01 09:53:20.29518
\.


--
-- TOC entry 5037 (class 0 OID 16507)
-- Dependencies: 220
-- Data for Name: bookings; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.bookings (id, user_id, room_id, check_in, check_out, total_price, status, created_at, deleted_at, discount_code, discount_percent) FROM stdin;
96	17	21	2025-07-11	2025-07-13	3000000.00	canceled	2025-07-11 03:35:27.854148	2025-07-10 20:37:14	\N	0.00
49	1	21	2025-06-17	2025-06-18	1500000.00	done	2025-06-15 09:56:28.191435	\N	\N	\N
41	14	11	2025-06-11	2025-06-12	800000.00	done	2025-06-10 22:31:05.172833	\N	\N	\N
76	3	5	2025-06-19	2025-06-20	650000.00	done	2025-06-19 00:25:04.498031	2025-06-18 17:27:29	\N	\N
97	15	21	2025-07-11	2025-07-13	3000000.00	canceled	2025-07-11 03:40:18.77648	2025-07-10 20:48:59	\N	0.00
77	1	2	2025-06-25	2025-06-26	500000.00	done	2025-06-19 01:22:19.490474	2025-06-18 18:25:28	\N	\N
78	1	43	2025-06-19	2025-06-20	500000.00	pending	2025-06-19 05:59:57.046071	2025-06-18 23:01:52	\N	\N
69	1	6	2025-06-17	2025-06-18	500000.00	confirmed	2025-06-17 14:33:57.296701	\N	\N	\N
35	14	2	2025-05-25	2025-05-26	500000.00	confirmed	2025-05-25 18:07:23.663512	\N	\N	\N
34	14	12	2025-05-26	2025-05-27	800000.00	confirmed	2025-05-25 17:47:12.839313	\N	\N	\N
98	15	23	2025-07-11	2025-07-12	1500000.00	pending	2025-07-11 05:33:54.999209	\N	NEWUSER11	11.00
99	15	4	2025-07-11	2025-07-12	500000.00	pending	2025-07-11 05:36:37.998163	2025-07-10 22:51:13	NEWUSER11	11.00
83	11	41	2025-06-22	2025-06-23	500000.00	pending	2025-06-20 16:40:42.036255	2025-06-20 09:42:58	\N	\N
82	11	39	2025-06-22	2025-06-23	500000.00	confirmed	2025-06-20 14:29:42.390542	2025-06-20 09:43:05	\N	\N
81	11	41	2025-06-27	2025-06-28	500000.00	confirmed	2025-06-20 13:30:44.562471	2025-06-20 09:43:10	\N	\N
54	1	12	2025-06-17	2025-06-18	800000.00	confirmed	2025-06-17 02:19:27.103074	\N	\N	\N
100	17	4	2025-07-11	2025-07-12	500000.00	pending	2025-07-11 05:53:50.662931	\N	\N	0.00
57	1	12	2025-06-20	2025-06-21	800000.00	pending	2025-06-17 03:02:07.727485	\N	\N	\N
58	1	9	2025-06-17	2025-06-18	500000.00	confirmed	2025-06-17 03:09:36.873484	\N	\N	\N
80	1	2	2025-06-24	2025-06-25	500000.00	done	2025-06-20 13:26:55.855624	2025-06-20 10:03:09	\N	\N
85	7	41	2025-06-29	2025-06-30	500000.00	pending	2025-06-20 19:43:18.297974	2025-06-21 09:10:25	\N	\N
84	2	41	2025-06-22	2025-06-23	500000.00	pending	2025-06-20 16:44:58.815883	2025-06-21 09:10:29	\N	\N
79	11	41	2025-06-24	2025-06-25	500000.00	pending	2025-06-19 06:41:58.601841	2025-06-21 09:10:41	\N	\N
86	1	41	2025-06-23	2025-06-24	500000.00	pending	2025-06-21 16:12:04.662459	2025-06-21 15:33:16	\N	\N
87	1	13	2025-06-23	2025-06-24	800000.00	pending	2025-06-21 22:34:10.861029	2025-06-21 15:35:03	\N	\N
70	2	9	2025-06-24	2025-06-26	1000000.00	pending	2025-06-17 14:36:15.965123	\N	\N	\N
71	1	8	2025-06-17	2025-06-18	650000.00	confirmed	2025-06-17 17:04:01.313668	\N	\N	\N
88	14	12	2025-06-23	2025-06-24	800000.00	pending	2025-06-21 22:46:48.629572	2025-06-22 08:34:51	\N	\N
101	1	2	2025-07-11	2025-07-12	500000.00	pending	2025-07-11 17:53:44.163008	\N	\N	0.00
102	1	2	2025-07-13	2025-07-14	500000.00	pending	2025-07-11 17:57:24.202746	\N	\N	0.00
89	12	41	2025-06-27	2025-06-28	500000.00	done	2025-06-22 15:36:44.74063	2025-06-22 09:19:12	NEWUSER10	10.00
48	1	21	2025-06-15	2025-06-16	1500000.00	pending	2025-06-15 09:49:38.685466	2025-06-18 03:25:57	\N	\N
40	1	3	2025-06-15	2025-06-18	1500000.00	done	2025-06-10 22:01:57.87695	2025-06-18 03:28:35	\N	\N
73	2	16	2025-06-18	2025-06-19	800000.00	confirmed	2025-06-18 00:29:26.442876	\N	\N	\N
103	3	11	2025-07-14	2025-07-15	800000.00	confirmed	2025-07-14 12:05:44.694346	\N	NEWUSER11	11.00
90	1	3	2025-06-23	2025-06-24	500000.00	done	2025-06-22 16:20:35.803466	\N	NEWUSER10	10.00
75	3	2	2025-06-19	2025-06-20	500000.00	done	2025-06-18 10:34:41.476358	2025-07-14 05:11:25	\N	\N
52	1	24	2025-06-17	2025-06-18	1500000.00	confirmed	2025-06-17 01:58:12.945577	\N	\N	\N
91	1	41	2025-07-01	2025-07-02	500000.00	done	2025-06-26 14:17:27.810986	\N	NEWUSER10	10.00
50	1	21	2025-06-19	2025-06-20	1500000.00	pending	2025-06-15 09:59:39.546819	2025-06-26 07:34:53	\N	\N
51	1	4	2025-06-16	2025-06-17	500000.00	pending	2025-06-16 03:53:43.758264	2025-07-06 20:31:59	\N	\N
92	9	41	2025-07-08	2025-07-09	500000.00	pending	2025-07-07 20:29:43.389259	2025-07-08 13:11:14	\N	0.00
93	3	12	2025-07-10	2025-07-11	800000.00	pending	2025-07-08 20:30:27.734831	2025-07-08 13:46:32	\N	0.00
94	3	12	2025-07-10	2025-07-11	800000.00	pending	2025-07-08 20:46:47.643307	2025-07-08 13:47:02	\N	0.00
95	3	12	2025-07-10	2025-07-11	800000.00	pending	2025-07-08 20:47:16.882919	2025-07-08 13:47:32	\N	0.00
33	14	11	2025-05-23	2025-05-24	800000.00	pending	2025-05-24 00:00:00.305152	2025-07-10 12:36:13	\N	\N
104	3	4	2025-07-14	2025-07-15	500000.00	done	2025-07-14 12:16:13.457681	\N	NEWUSER11	11.00
53	1	5	2025-06-17	2025-06-18	650000.00	pending	2025-06-17 02:01:10.467464	\N	\N	\N
\.


--
-- TOC entry 5039 (class 0 OID 16514)
-- Dependencies: 222
-- Data for Name: contacts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.contacts (id, name, email, phone, subject, message, created_at, replied, deleted_at) FROM stdin;
1	Nguyễn Văn A	nva@gmail.com	0912345678	Góp ý dịch vụ	Tôi thấy dịch vụ khá tốt nhưng nên cải thiện tốc độ check-in.	2025-04-10 12:42:55.079749	f	\N
2	Trần Thị B	ttb@yahoo.com	0987654321	Liên hệ đặt phòng	Mình muốn hỏi về phòng VIP còn trống không?	2025-04-10 12:42:55.079749	f	\N
3	Trần Thị B	ttb@yahoo.com	0987654321	\N	Mình muốn hỏi về phòng VIP còn trống không?	2025-04-10 12:42:55.079749	f	\N
4	Nguyễn Giang Sơn	ttb@yahoo.com	037742761	\N	Mình muốn hỏi về phòng VIP còn trống không?	2025-06-06 20:45:37.900244	f	\N
6	giang sơn	1@gmail.com	0377492844	\N	adasdasd	2025-06-06 20:54:39.365227	f	\N
7	giang sơn	nguyengiangson1942003@gmail.com	0377492876	\N	adasdassadas	2025-06-06 22:08:43.215027	f	\N
9	Phúc kẹo	phuckeo12341@gmail.com	0377492876	\N	aaaaa	2025-07-08 10:03:15.424594	f	\N
10	a	nguyengiangson1904@gmail.com	0377492876	\N	a	2025-07-08 10:21:13.345589	t	\N
5	giang sơn	nguyengiangson1942003@gmail.com	0377492876	\N	adasdad	2025-06-06 20:52:06.038683	t	\N
11	giang sơn	nguyengiangson1942003@gmail.com	037749287611	\N	1111111	2025-07-08 21:16:53.439824	f	\N
8	Son	cruzjosephinecud124@hotmail.com	0377492876	\N	acacacac	2025-06-15 00:03:35.986109	t	\N
\.


--
-- TOC entry 5041 (class 0 OID 16521)
-- Dependencies: 224
-- Data for Name: conversations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.conversations (id, user_id, start_time, end_time, status, agent_id) FROM stdin;
1	1	2025-04-08 12:45:36.67738	2025-04-08 12:55:36.67738	finished	2
2	2	2025-04-09 12:45:36.67738	\N	active	2
3	\N	2025-05-29 02:08:44.839929	\N	active	\N
4	\N	2025-05-29 02:22:25.326233	\N	active	\N
5	\N	2025-05-29 02:22:25.595993	\N	active	\N
6	\N	2025-05-29 02:22:31.640092	\N	active	\N
7	\N	2025-05-29 02:22:31.938169	\N	active	\N
8	\N	2025-05-29 02:22:34.249295	\N	active	\N
9	\N	2025-05-29 02:22:34.675098	\N	active	\N
10	\N	2025-05-30 07:40:17	\N	active	\N
11	\N	2025-05-30 07:40:41	\N	active	\N
12	\N	2025-05-30 07:41:45	\N	active	\N
13	\N	2025-05-30 07:42:09	\N	active	\N
14	\N	2025-05-30 07:46:17	\N	active	\N
15	\N	2025-05-30 07:46:50	\N	active	\N
16	\N	2025-05-30 08:04:13	\N	active	\N
17	\N	2025-05-30 10:49:45	\N	active	\N
18	\N	2025-05-30 11:40:29	\N	active	\N
19	\N	2025-05-30 11:40:55	\N	active	\N
20	\N	2025-06-06 15:15:05	\N	active	\N
21	\N	2025-06-06 15:15:08	\N	active	\N
22	\N	2025-06-26 05:40:06	\N	active	\N
23	1	2025-07-04 22:38:17	\N	active	\N
24	1	2025-07-04 22:38:53	\N	active	\N
25	1	2025-07-04 23:19:29	\N	active	\N
26	1	2025-07-04 23:34:31	\N	active	\N
27	1	2025-07-04 23:37:50	\N	active	\N
28	9	2025-07-07 15:52:23	\N	active	\N
29	3	2025-07-08 14:28:53	\N	active	\N
30	1	2025-07-10 12:02:34	\N	active	\N
31	1	2025-07-12 22:12:24	\N	active	\N
32	1	2025-07-22 02:55:20	\N	active	\N
33	1	2025-07-23 00:58:09	\N	active	\N
\.


--
-- TOC entry 5043 (class 0 OID 16527)
-- Dependencies: 226
-- Data for Name: discounts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.discounts (id, code, description, discount_type, discount_value, start_date, end_date, status, created_at, updated_at, deleted_at) FROM stdin;
2	SERVICE10	10% discount on additional services, limited to 1 use	percent	10.00	2025-07-08 00:00:00	2025-07-15 00:00:00	active	2025-04-05 13:58:41.364971	2025-07-07 15:34:17	2025-07-07 15:34:17
9	aa	\N	percent	11.00	2025-07-08 00:00:00	2025-07-09 00:00:00	active	2025-07-07 15:34:05	2025-07-07 15:34:20	2025-07-07 15:34:20
3	STAY3ANDSERVICE10	10% discount for stays of 3 nights or more with additional services, limited to 1 use	percent	10.00	2025-07-11 00:00:00	2025-07-31 00:00:00	active	2025-04-05 13:58:41.364971	2025-07-11 11:51:35	\N
11	AAAAAA	AAAA	percent	10.00	2025-07-11 00:00:00	2025-07-30 00:00:00	active	2025-07-11 11:52:24	2025-07-11 11:52:24	\N
8	NEWUSER12	Viper	percent	10.00	2025-06-18 00:00:00	2025-06-20 00:00:00	active	2025-06-18 16:14:27	2025-06-18 17:15:04	2025-06-18 17:15:04
5	YESTERDAY	quá tuỵt dời	percent	15.00	2025-06-13 00:00:00	2025-06-13 00:00:00	expired	2025-06-12 21:49:30	2025-06-18 17:17:45	2025-06-18 17:17:45
4	NEWUSER11	10% discount for new users, valid for 7 days from account creation	percent	11.00	2025-07-08 00:00:00	2025-07-15 00:00:00	expired	2025-05-19 17:09:56.615583	2025-07-22 00:38:46	\N
1	NEWUSER10	10% discount for new users, valid for 7 days from account creation	percent	10.00	2025-07-11 00:00:00	2025-07-22 00:00:00	expired	2025-04-05 13:58:41.364971	2025-07-22 00:38:46	\N
\.


--
-- TOC entry 5045 (class 0 OID 16541)
-- Dependencies: 228
-- Data for Name: faq; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.faq (id, question, answer, category, created_at) FROM stdin;
2	What time is the check-in?	Check-in time is 2:00 PM.	General	2025-04-05 13:48:40.944741
3	Khách sạn có xe đưa đón không?	Chúng tôi cung cấp dịch vụ xe đưa đón với một khoản phí.	Services	2025-04-05 13:48:40.944741
4	Does the hotel offer shuttle service?	We offer shuttle service for an additional fee.	Services	2025-04-05 13:48:40.944741
5	Có thể hủy đặt phòng không?	Bạn có thể hủy đặt phòng miễn phí trong vòng 24 giờ trước giờ nhận phòng.	Bookings	2025-04-05 13:48:40.944741
7	Khách sạn có chỗ đỗ xe không?	Chúng tôi có khu vực đỗ xe miễn phí cho khách lưu trú.	Facilities	2025-04-05 13:48:40.944741
8	Does the hotel have parking?	We have free parking available for guests.	Facilities	2025-04-05 13:48:40.944741
9	Khách sạn có cho phép thú cưng không?	Khách sạn không cho phép thú cưng trong phòng.	Policies	2025-04-05 13:48:40.944741
10	Does the hotel allow pets?	Pets are not allowed in the rooms.	Policies	2025-04-05 13:48:40.944741
1	Giờ nhận phòng là mấy giờ?	Giờ nhận phòng là 14:00.	General	2025-04-05 13:48:40.944741
6	Can I cancel my booking?	You can cancel your booking for free within 24 hours of check-in time	Bookings	2025-04-05 13:48:40.944741
\.


--
-- TOC entry 5072 (class 0 OID 25019)
-- Dependencies: 255
-- Data for Name: hotel_info; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.hotel_info (id, key, value) FROM stdin;
1	hotel_name	Khách sạn Ocean
2	address	123 Đường Biển, Quận 1, Thủ Đô Hà Nội
3	hotline	0123 456 789
4	email	booking@oceanhotel.vn
5	website	https://oceanhotel.vn/booking
6	booking_steps	Chọn phòng → Nhập thông tin → Xác nhận thanh toán
7	checkin_time	6:00
8	checkout_time	12:00
9	breakfast_info	Buffet sáng phục vụ từ 6:30 – 10:00 tại tầng 2
10	wifi_info	Wifi miễn phí toàn khách sạn
11	room_types	Single, Suite, Double
12	pool_info	Hồ bơi mở từ 6:00 – 20:00, miễn phí cho khách lưu trú
13	parking_info	Có bãi đậu xe miễn phí, an ninh 24/7
14	payment_methods	Tiền mặt, thẻ ATM, Visa/Mastercard, Momo
15	cancellation_policy	Hủy miễn phí trước 24h, sau đó mất 50% giá trị phòng
16	child_policy	Trẻ dưới 6 tuổi miễn phí, từ 6-12 tuổi phụ thu 100.000đ
17	pet_policy	Không cho phép mang thú cưng
18	spa_info	Spa mở cửa 9:00 – 22:00, đặt lịch tại lễ tân
19	restaurant_info	2 nhà hàng: Hải sản (tầng 1), Buffet (tầng 2)
20	tour_info	Có tour đảo 1 ngày, giá từ 500.000đ/người
21	languages_supported	Tiếng Việt, Tiếng Anh
22	extra_bed_info	Phụ thu 200.000đ/giường phụ/đêm
23	loyalty_program_info	Tích điểm 5% mỗi đêm, đổi quà hoặc giảm giá
24	transportation_info	Dịch vụ đưa đón sân bay: 300.000đ/lượt
25	car_rental_service	Dịch vụ cho thuê xe di chuyển: 100.000đ/ngày
26	smoking_policy	Không hút thuốc trong phòng, có khu vực riêng cho hút thuốc
\.


--
-- TOC entry 5047 (class 0 OID 16548)
-- Dependencies: 230
-- Data for Name: images; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.images (id, object_type, object_id, image_url, created_at) FROM stdin;
1	room	1	/uploads/rooms/room_home1.jpg	2025-04-10 12:55:51.546503
2	room	2	/uploads/rooms/room_home2.jpg	2025-04-10 12:55:51.546503
3	room	3	/uploads/rooms/room_home3.jpg	2025-04-10 12:55:51.546503
4	service	1	/uploads/services/meal_service.jpg	2025-04-10 12:55:51.546503
105	service	2	/uploads/services/1751458767_service_shuttleservice_4.jpg	2025-07-14 11:32:27.050375
8	room	4	/uploads/rooms/room_home4.jpg	2025-05-11 20:39:03.10927
9	room	5	/uploads/rooms/room_home5.jpg	2025-05-14 19:50:58.513608
10	room	6	/uploads/rooms/room_home6.jpg	2025-05-14 19:50:58.513608
11	room	7	/uploads/rooms/room_home7.jpg	2025-05-14 19:50:58.513608
29	room	25	/uploads/rooms/room_home3.jpg	2025-05-14 19:50:58.513608
30	service	1	/uploads/services/service_breakfast_4.jpg	2025-04-10 12:55:51.546503
31	service	1	/uploads/services/service_breakfast_3.jpg	2025-04-10 12:55:51.546503
32	service	1	/uploads/services/service_breakfast_2.jpg	2025-04-10 12:55:51.546503
12	room	8	/uploads/rooms/room_home8.jpg	2025-05-14 19:50:58.513608
13	room	9	/uploads/rooms/room_home9.jpg	2025-05-14 19:50:58.513608
14	room	10	/uploads/rooms/room_home10.jpg	2025-05-14 19:50:58.513608
15	room	11	/uploads/rooms/room_home11.jpg	2025-05-14 19:50:58.513608
37	service	3	/uploads/services/service_fitness&swimming_4.jpg	2025-04-10 12:55:51.546503
38	service	3	/uploads/services/service_fitness&swimming_3.jpg	2025-04-10 12:55:51.546503
39	service	3	/uploads/services/service_fitness&swimming_2.jpg	2025-04-10 12:55:51.546503
40	service	3	/uploads/services/service_fitness&swimming_1.jpg	2025-04-10 12:55:51.546503
16	room	12	/uploads/rooms/room_home12.jpg	2025-05-14 19:50:58.513608
17	room	13	/uploads/rooms/room_home13.jpg	2025-05-14 19:50:58.513608
18	room	14	/uploads/rooms/room_home14.jpg	2025-05-14 19:50:58.513608
19	room	15	/uploads/rooms/room_home15.jpg	2025-05-14 19:50:58.513608
20	room	16	/uploads/rooms/room_home16.jpg	2025-05-14 19:50:58.513608
21	room	17	/uploads/rooms/room_home17.jpg	2025-05-14 19:50:58.513608
22	room	18	/uploads/rooms/room_home18.jpg	2025-05-14 19:50:58.513608
24	room	20	/uploads/rooms/room_home19.jpg	2025-05-14 19:50:58.513608
25	room	21	/uploads/rooms/room_home20.jpg	2025-05-14 19:50:58.513608
27	room	23	/uploads/rooms/room_home1.jpg	2025-05-14 19:50:58.513608
28	room	24	/uploads/rooms/room_home2.jpg	2025-05-14 19:50:58.513608
65	room	39	/uploads/rooms/room_home5.jpg	2025-06-19 05:08:30.391616
67	room	41	/uploads/rooms/room_home6.jpg	2025-06-19 05:31:27.339488
26	room	22	/uploads/rooms/room_home5.jpg	2025-05-14 19:50:58.513608
84	service	2	/uploads/services/1751458767_service_shuttleservice_1.jpg	2025-07-02 19:19:27.817403
85	service	2	/uploads/services/1751458767_service_shuttleservice_2.jpg	2025-07-02 19:19:27.818878
86	service	2	/uploads/services/1751458767_service_shuttleservice_3.jpg	2025-07-02 19:19:27.820168
\.


--
-- TOC entry 5049 (class 0 OID 16556)
-- Dependencies: 232
-- Data for Name: invoice_items; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.invoice_items (id, invoice_id, description, amount, quantity, total_amount) FROM stdin;
5	8	Phòng 	500000.00	3	1500000.00
8	11	Phòng 	1500000.00	1	1500000.00
9	12	Phòng 	650000.00	1	650000.00
11	14	Phòng 	500000.00	1	500000.00
12	15	Phòng 	500000.00	1	500000.00
13	16	Phòng 	500000.00	1	500000.00
14	17	Phòng 	500000.00	1	500000.00
15	18	Phòng 	500000.00	1	500000.00
16	21	Phòng 	500000.00	1	500000.00
\.


--
-- TOC entry 5051 (class 0 OID 16561)
-- Dependencies: 234
-- Data for Name: invoices; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.invoices (id, booking_id, total_amount, status, created_at, deleted_at) FROM stdin;
8	40	1500000.00	paid	2025-06-15 00:36:07.904947	2025-06-18 03:28:35
11	49	1500000.00	paid	2025-06-18 11:27:42.182451	\N
12	76	650000.00	paid	2025-06-19 00:26:48.162553	2025-06-18 17:27:29
13	77	500000.00	paid	2025-06-19 01:25:10.358598	2025-06-18 18:25:28
14	80	500000.00	paid	2025-06-20 17:03:05.228332	2025-06-20 10:03:09
15	89	450000.00	paid	2025-06-22 16:17:54.109846	2025-06-22 09:19:12
16	90	450000.00	paid	2025-06-22 16:21:56.533094	\N
18	91	540000.00	paid	2025-06-26 14:18:38.12207	\N
17	75	600000.00	paid	2025-06-22 16:24:03.53064	2025-07-14 05:11:25
21	104	578500.00	paid	2025-07-14 12:20:02.170774	\N
\.


--
-- TOC entry 5053 (class 0 OID 16568)
-- Dependencies: 236
-- Data for Name: messages; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.messages (id, conversation_id, sender, message, "timestamp", deleted_at) FROM stdin;
1	1	user	Xin chào, tôi cần hỗ trợ đặt phòng.	2025-04-10 12:47:25.097216	\N
2	1	agent	Dạ vâng, anh/chị muốn đặt phòng loại nào ạ?	2025-04-10 12:47:25.097216	\N
3	1	user	Tôi muốn đặt phòng Deluxe trong 2 ngày.	2025-04-10 12:47:25.097216	\N
4	2	user	Khách sạn có phục vụ ăn sáng không?	2025-04-10 12:47:25.097216	\N
5	2	bot	Khách sạn có phục vụ bữa sáng miễn phí từ 6h30 đến 9h30.	2025-04-10 12:47:25.097216	\N
6	14	user	Khách sạn có xe đưa đón không?	2025-05-30 07:46:17	\N
7	14	bot	Chúng tôi cung cấp dịch vụ xe đưa đón với một khoản phí.	2025-05-30 07:46:17	\N
8	15	user	Khách sạn có xe đưa đón không?	2025-05-30 07:46:50	\N
9	15	bot	Chúng tôi cung cấp dịch vụ xe đưa đón với một khoản phí.	2025-05-30 07:46:50	\N
10	16	user	Khách sạn có xe đưa đón không?	2025-05-30 08:04:13	\N
11	16	bot	Chúng tôi cung cấp dịch vụ xe đưa đón với một khoản phí.	2025-05-30 08:04:13	\N
12	17	user	chào	2025-05-30 10:49:45	\N
13	17	bot	Xin lỗi, tôi chưa biết trả lời.	2025-05-30 10:49:45	\N
14	18	user	Có thể hủy đặt phòng không?	2025-05-30 11:40:29	\N
15	18	bot	Bạn có thể hủy đặt phòng miễn phí trong vòng 24 giờ trước giờ nhận phòng.	2025-05-30 11:40:29	\N
16	19	user	Làm cách nào để đặt phòng	2025-05-30 11:40:55	\N
17	19	bot	Xin lỗi, tôi chưa thể trả lời câu hỏi đó.	2025-05-30 11:40:55	\N
18	20	user	Chúng tôi có khu vực đỗ xe miễn phí cho khách lưu trú.	2025-06-06 15:15:05	\N
19	20	bot	Xin lỗi, tôi chưa thể trả lời câu hỏi đó.	2025-06-06 15:15:05	\N
20	21	user	Khách sạn có chỗ đỗ xe không?	2025-06-06 15:15:08	\N
21	21	bot	Chúng tôi có khu vực đỗ xe miễn phí cho khách lưu trú.	2025-06-06 15:15:08	\N
22	22	user	aaa	2025-06-26 05:40:06	\N
23	22	bot	aaa	2025-06-26 05:40:06	\N
24	23	user	What time is the check-in?	2025-07-04 22:38:17	\N
25	23	bot	Check-in time is 2:00 PM.	2025-07-04 22:38:17	\N
26	24	user	làm sao để có thể booking?	2025-07-04 22:38:53	\N
27	24	bot	Xin chào! Để đặt phòng tại khách sạn Ocean, bạn có thể truy cập website của chúng tôi để đặt trực tuyến hoặc liên hệ trực tiếp với bộ phận đặt phòng theo số điện thoại +84 XXX XXX XXX. Chúng tôi rất sẵn lòng hỗ trợ bạn. Cảm ơn bạn đã quan tâm đến khách sạn Ocean!	2025-07-04 22:38:53	\N
28	25	user	Khách sạn mấy giờ thì cho nhận phòng và trả phòng?	2025-07-04 23:19:29	\N
29	25	bot	Khách sạn Ocean cho nhận phòng từ 6:00 và yêu cầu trả phòng trước 12:00 trưa nhé!	2025-07-04 23:19:29	\N
30	25	user	What time is the check-in?	2025-07-04 23:20:11	\N
31	25	bot	Check-in time is 2:00 PM.	2025-07-04 23:20:11	\N
32	25	user	chào bạn	2025-07-04 23:21:13	\N
33	25	bot	Chào bạn! Chào mừng bạn đến với Khách sạn Ocean. Có điều gì tôi có thể giúp bạn?	2025-07-04 23:21:13	\N
34	25	user	Khách sạn có chỗ đỗ xe không?	2025-07-04 23:27:24	\N
35	25	bot	Chúng tôi có khu vực đỗ xe miễn phí cho khách lưu trú.	2025-07-04 23:27:24	\N
36	26	user	Có thể hủy đặt phòng không?	2025-07-04 23:34:31	\N
37	26	bot	Bạn có thể hủy đặt phòng miễn phí trong vòng 24 giờ trước giờ nhận phòng.	2025-07-04 23:34:31	\N
38	27	user	Có thể hủy đặt phòng không?	2025-07-04 23:37:50	\N
39	27	bot	Bạn có thể hủy đặt phòng miễn phí trong vòng 24 giờ trước giờ nhận phòng.	2025-07-04 23:37:50	\N
40	28	user	chào bạn	2025-07-07 15:52:23	\N
41	28	bot	Chào bạn! Chào mừng bạn đến với Khách sạn Ocean. Có điều gì Ocean có thể hỗ trợ bạn không ạ?	2025-07-07 15:52:23	\N
42	28	user	tôi muốn đặt phòng	2025-07-07 15:52:33	\N
43	28	bot	Chào bạn, để đặt phòng tại Khách sạn Ocean, bạn có thể truy cập trang web https://oceanhotel.vn/booking để chọn phòng, nhập thông tin và xác nhận thanh toán. Nếu có bất kỳ thắc mắc nào, bạn cũng có thể gọi đến Hotline: 0123 456 789 để được hỗ trợ trực tiếp. Chúng tôi sẽ rất vui lòng chào đón bạn tại khách sạn Ocean!	2025-07-07 15:52:33	\N
44	29	user	aaaaaaaaaaaaaa ?	2025-07-08 14:28:53	\N
45	29	bot	Xin chào! Chúng tôi là Khách sạn Ocean, nơi bạn có thể tìm thấy sự thoải mái và tiện nghi tại địa chỉ 123 Đường Biển, Quận 1, Thủ Đô Hà Nội. Nếu bạn có bất kỳ câu hỏi nào về dịch vụ hoặc thông tin đặt phòng, hãy liên hệ với chúng tôi qua Hotline: 0123 456 789 hoặc email: booking@oceanhotel.vn. Để biết thêm thông tin chi tiết và đặt phòng trực tuyến, bạn có thể truy cập vào trang web của chúng tôi tại https://oceanhotel.vn/booking. Chúng tôi rất mong được phục vụ bạn!	2025-07-08 14:28:53	\N
46	29	user	gà rán có ngon không ?	2025-07-08 14:29:48	\N
47	29	bot	Xin lỗi, gà rán không phải là một dịch vụ hoặc tiện ích mà khách sạn Ocean cung cấp. Nếu bạn cần thông tin về dịch vụ hoặc tiện ích khác tại khách sạn, vui lòng cho biết để chúng tôi hỗ trợ bạn được không?	2025-07-08 14:29:48	\N
48	30	user	a	2025-07-10 12:02:34	\N
49	30	bot	Check-in time is 2:00 PM.	2025-07-10 12:02:34	\N
50	31	user	Làm thế nào để tôi có thể đặt phòng	2025-07-12 22:12:24	\N
51	31	bot	Xin chào! Để đặt phòng tại Khách sạn Ocean, bạn có thể truy cập trang web của chúng tôi tại https://oceanhotel.vn/booking để chọn phòng, nhập thông tin và xác nhận thanh toán. Ngoài ra, bạn cũng có thể gọi đến số hotline của chúng tôi: 0123 456 789 để được hỗ trợ đặt phòng.Thông tin thêm bạn cần biết là thời gian checkin là 6:00 và thời gian checkout là 12:00. Nếu cần thêm thông tin hoặc hỗ trợ, đừng ngần ngại liên hệ với chúng tôi!	2025-07-12 22:12:24	\N
52	32	user	chào bạn	2025-07-22 02:55:21	\N
53	32	bot	Chào bạn! Chào mừng bạn đến với Khách sạn Ocean. Bạn cần thông tin hoặc hỗ trợ gì ạ?	2025-07-22 02:55:21	\N
54	32	user	tôi chưa đăng nhập tài khoản thì có thể đặt phòng được không	2025-07-22 02:55:47	\N
55	32	bot	Chào bạn! Đúng vậy, bạn hoàn toàn có thể đặt phòng mà không cần đăng nhập tài khoản. Bạn chỉ cần truy cập vào trang web của chúng tôi tại địa chỉ https://oceanhotel.vn/booking, sau đó chọn phòng, nhập thông tin cần thiết và tiến hành xác nhận thanh toán. Nếu có bất kỳ thắc mắc nào khác, hãy thông báo cho tôi nhé!	2025-07-22 02:55:47	\N
56	33	user	cho tôi thông tin về khách sạn của mình	2025-07-23 00:58:09	\N
57	33	bot	Chào bạn! Khách sạn của bạn là Khách sạn Ocean, địa chỉ tại 123 Đường Biển, Quận 1, Thủ Đô Hà Nội. Để liên hệ hoặc đặt phòng, bạn có thể gọi Hotline: 0123 456 789 hoặc gửi email đến booking@oceanhotel.vn. Website chính thức của khách sạn là https://oceanhotel.vn/booking.\n\nKhách sạn có các loại phòng như Single, Suite, Double. Thời gian check-in là từ 6:00 và check-out là vào lúc 12:00. Bữa sáng buffet được phục vụ từ 6:30 đến 10:00 tại tầng 2 của khách sạn.\n\nWifi miễn phí toàn bộ khách sạn và hồ bơi mở từ 6:00 đến 20:00, miễn phí cho khách lưu trú. Bãi đậu xe cũng miễn phí và được bảo vệ 24/7.\n\nKhách sạn chấp nhận thanh toán bằng tiền mặt, thẻ ATM, Visa/Mastercard và MoMo. Đối với việc hủy phòng, bạn có thể hủy miễn phí trước 24h, sau đó sẽ phải trả 50% giá trị phòng.\n\nKhách sạn không cho phép mang thú cưng và có chính sách đối với trẻ em: trẻ dưới 6 tuổi miễn phí, từ 6-12 tuổi phụ thu 100.000đ. \n\nNgoài ra, khách sạn còn có dịch vụ spa mở cửa từ 9:00 đến 22:00, bạn có thể đặt lịch tại lễ tân. Có 2 nhà hàng trong khách sạn là nhà hàng Hải sản t	2025-07-23 00:58:09	\N
58	33	user	aa	2025-07-23 00:59:37	\N
59	33	bot	Chào bạn, có thể mình giúp gì được cho bạn về Khách sạn Ocean ạ?	2025-07-23 00:59:37	\N
\.


--
-- TOC entry 5068 (class 0 OID 16767)
-- Dependencies: 251
-- Data for Name: migrations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.migrations (id, migration, batch) FROM stdin;
1	2014_10_12_100000_create_password_reset_tokens_table	1
2	2019_08_19_000000_create_failed_jobs_table	1
3	2019_12_14_000001_create_personal_access_tokens_table	1
4	2025_04_24_082421_create_user_tokens_table	2
\.


--
-- TOC entry 5055 (class 0 OID 16576)
-- Dependencies: 238
-- Data for Name: payments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.payments (id, booking_id, amount, payment_date, method, status, momo_order_id, deleted_at) FROM stdin;
15	35	500000.00	2025-05-25 11:07:24	atm	paid	6832f9ec0939a	\N
59	90	450000.00	2025-06-22 09:21:35	atm	paid	6857cae414c62	\N
14	34	800000.00	2025-05-25 10:47:13	atm	paid	\N	\N
28	52	1600000.00	2025-06-16 18:58:13	atm	unpaid	6850694555797	\N
29	53	750000.00	2025-06-16 19:01:10	atm	unpaid	685069f6b32c2	\N
30	54	900000.00	2025-06-16 19:19:27	atm	paid	68506e3f5828c	\N
33	57	900000.00	2025-06-16 20:02:08	atm	unpaid	685078401aab0	\N
34	58	600000.00	2025-06-16 20:09:37	atm	paid	68507a01205a0	\N
38	69	600000.00	2025-06-17 07:33:57	atm	unpaid	68511a65a4c75	\N
39	70	1200000.00	2025-06-17 07:36:16	atm	unpaid	68511af052655	\N
40	71	750000.00	2025-06-17 10:04:01	atm	paid	68513d918ac93	\N
42	73	900000.00	2025-06-17 17:29:26	atm	paid	6851a5f6cf7b7	\N
60	91	540000.00	2025-06-26 07:17:28	atm	paid	685cf4081ec87	\N
24	48	1600000.00	2025-06-15 02:49:39	atm	unpaid	684e34c2e94fd	2025-06-18 03:25:57
19	40	2500000.00	2025-06-10 15:01:58	atm	paid	684848e647a95	2025-06-18 03:28:35
25	49	1500000.00	2025-06-18 04:27:06	atm	paid	684e365c6e549	\N
26	50	1500000.00	2025-06-15 02:59:40	atm	unpaid	684e371bf3f9e	2025-06-26 07:34:53
45	76	750000.00	2025-06-18 17:25:04	atm	paid	6852f670b9091	2025-06-18 17:27:29
27	51	600000.00	2025-06-15 20:53:44	atm	unpaid	684f32d83022b	2025-07-06 20:31:59
46	77	540000.00	2025-06-18 18:24:21	atm	paid	685303dbd310e	2025-06-18 18:25:28
47	78	600000.00	2025-06-18 22:59:58	atm	unpaid	685344ed92202	2025-06-18 23:01:52
61	92	550000.00	2025-07-07 13:29:44	atm	unpaid	686bcbc7a6ddf	2025-07-08 13:11:14
52	83	540000.00	2025-06-20 09:40:42	atm	unpaid	68552c9a62515	2025-06-20 09:42:58
51	82	540000.00	2025-06-20 07:29:43	atm	paid	68550de6bae94	2025-06-20 09:43:05
50	81	837000.00	2025-06-20 06:30:45	atm	paid	68550014cbddc	2025-06-20 09:43:10
49	80	540000.00	2025-06-20 06:26:56	atm	paid	6854ff303b8eb	2025-06-20 10:03:09
54	85	540000.00	2025-06-20 12:43:19	atm	unpaid	68555766e7630	2025-06-21 09:10:25
53	84	540000.00	2025-06-20 09:44:59	atm	unpaid	68552d9b2c562	2025-06-21 09:10:29
48	79	540000.00	2025-06-18 23:41:59	atm	unpaid	68534ec6e6687	2025-06-21 09:10:41
55	86	540000.00	2025-06-21 09:12:05	atm	unpaid	685677650ee28	2025-06-21 15:33:16
56	87	900000.00	2025-06-21 15:34:11	atm	unpaid	6856d0f34ee74	2025-06-21 15:35:03
57	88	810000.00	2025-06-21 15:46:49	atm	unpaid	6856d3e90da6e	2025-06-22 08:34:51
62	93	800000.00	2025-07-08 13:30:28	atm	unpaid	686d1d7409778	2025-07-08 13:46:32
58	89	540000.00	2025-06-22 08:38:40	atm	paid	6857c09d0f60c	2025-06-22 09:19:12
63	94	800000.00	2025-07-08 13:46:48	atm	unpaid	686d214805440	2025-07-08 13:47:02
64	95	800000.00	2025-07-08 13:47:17	atm	unpaid	686d2165266b9	2025-07-08 13:47:32
13	33	800000.00	2025-05-23 17:00:00	atm	paid	\N	2025-07-10 12:36:13
65	96	3300000.00	2025-07-10 20:35:28	atm	unpaid	687024104b54b	2025-07-10 20:37:14
66	97	3300000.00	2025-07-10 20:40:19	atm	unpaid	687025330d2f3	2025-07-10 20:48:59
67	98	1557500.00	2025-07-10 22:33:55	atm	unpaid	68703fd360f51	\N
68	99	667500.00	2025-07-10 22:36:38	atm	unpaid	6870407665ebe	2025-07-10 22:51:13
69	100	500000.00	2025-07-10 22:53:51	atm	unpaid	6870447ee5dee	\N
70	101	980000.00	2025-07-11 10:53:44	atm	unpaid	6870ed388b10f	\N
71	102	980000.00	2025-07-11 10:57:24	qr	unpaid	6870ee1476c17	\N
72	103	845500.00	2025-07-14 05:05:45	atm	paid	687490291f2ac	\N
44	75	600000.00	2025-06-18 03:34:42	atm	paid	685233d1d1896	2025-07-14 05:11:25
73	104	578500.00	2025-07-14 05:16:14	atm	paid	6874929dd46a3	\N
\.


--
-- TOC entry 5070 (class 0 OID 16793)
-- Dependencies: 253
-- Data for Name: personal_access_tokens; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.personal_access_tokens (id, tokenable_type, tokenable_id, name, token, abilities, last_used_at, expires_at, created_at, updated_at) FROM stdin;
30	App\\Models\\User	3	authToken	475b6f7a1616105e83c25d046c4a11f155ed8ab76f24e803a96e2a1843bd0af4	["*"]	2025-06-18 17:26:06	\N	2025-06-17 17:45:08	2025-06-18 17:26:06
2	App\\Models\\User	10	authToken	8957be487be9b3576552eb95f22e91dce39400a5365e3120744f05df8f4ee3b5	["*"]	2025-04-24 07:49:06	\N	2025-04-24 07:44:09	2025-04-24 07:49:06
31	App\\Models\\User	1	authToken	78d6cf42a559c01ec8e9a44429a37c5f38c7868771583ad0c64db48f84d38138	["*"]	\N	\N	2025-06-18 18:21:12	2025-06-18 18:21:12
19	App\\Models\\User	14	authToken	b63ac07768279db58a83a81c7e17abca0b18f0390dc1f925a458507e998ef4b9	["*"]	2025-05-25 13:05:31	\N	2025-05-14 14:07:35	2025-05-25 13:05:31
1	App\\Models\\User	9	authToken	773abf4addcd6996d87217e11c048b5eeca5932e438745935c6558de820a5fd1	["*"]	2025-04-24 07:52:14	\N	2025-04-21 07:59:11	2025-04-24 07:52:14
32	App\\Models\\User	11	authToken	7de50a16a06252b95fc1cf9812112838511ef9b3a81dcc212e4668f1cb5f1391	["*"]	\N	\N	2025-06-18 23:40:27	2025-06-18 23:40:27
33	App\\Models\\User	1	authToken	4c47dd4332b17f15901bc5a5768b5587e8a54548a491179a1723bdc441c727fa	["*"]	\N	\N	2025-06-20 06:24:42	2025-06-20 06:24:42
34	App\\Models\\User	11	authToken	eaecf74aa3cbbee952c977dee762378c8c07adf8635f1b6e9c8330abd73c76a5	["*"]	\N	\N	2025-06-20 06:29:41	2025-06-20 06:29:41
35	App\\Models\\User	2	authToken	b3fc6c89111faeee6ad28f958c4fc60ea4a78d55c297ddd9541fbc4eb6da43e7	["*"]	\N	\N	2025-06-20 09:42:32	2025-06-20 09:42:32
41	App\\Models\\User	1	authToken	bc368a2d8f4397b78528054c8785c6fcaf9fd4c209007c6d574ec929a0dceb12	["*"]	2025-06-23 09:22:37	\N	2025-06-22 09:19:28	2025-06-23 09:22:37
37	App\\Models\\User	7	authToken	d83298cc7bb38e23077bdb004428fff17cde20114b152a9d22421f143ea18eea	["*"]	2025-06-23 10:29:28	\N	2025-06-20 12:34:51	2025-06-23 10:29:28
21	App\\Models\\User	14	authToken	e3a46cf22a04022c3bf74cbcc16ee1f68aecdbe7598476c291121b1c4f4dab87	["*"]	2025-06-06 13:15:50	\N	2025-05-20 09:04:21	2025-06-06 13:15:50
36	App\\Models\\User	1	authToken	bc382ce101ff17b20c53c9a2510bfe5723bf00100e7749d1bc1c26cb8da9278c	["*"]	2025-06-20 10:09:57	\N	2025-06-20 10:01:50	2025-06-20 10:09:57
22	App\\Models\\User	14	authToken	96b9787128ac84badf0e728254497c8528a8d76d66e6624ad55269f871d10e22	["*"]	2025-06-06 15:08:13	\N	2025-06-06 15:03:42	2025-06-06 15:08:13
23	App\\Models\\User	14	authToken	7ce2c7df534e63903543f348c5cadab7a4b59ca68bf6583d8d93df89a42d251f	["*"]	2025-06-10 15:03:03	\N	2025-06-10 14:59:32	2025-06-10 15:03:03
24	App\\Models\\User	1	authToken	1055006b22925ed241d1cab912077d240aaf5f59cc6226f8882f142ad05541c7	["*"]	\N	\N	2025-06-13 20:47:55	2025-06-13 20:47:55
25	App\\Models\\User	1	authToken	05a448e1b185b46ce71b292c84049713db63a156f5bb828763e027e9321516ae	["*"]	\N	\N	2025-06-14 17:41:58	2025-06-14 17:41:58
38	App\\Models\\User	1	authToken	7b4825bcad14cd36739903c90a1090d8fac70f9ff59b6e670d47fbad15efe9d1	["*"]	\N	\N	2025-06-21 15:32:34	2025-06-21 15:32:34
26	App\\Models\\User	1	authToken	1c5552114a29f35d403b43089cc8cc802b4d183e338587e6de28338706525632	["*"]	\N	\N	2025-06-16 20:08:23	2025-06-16 20:08:23
3	App\\Models\\User	11	authToken	84f025d615eed151bf191760a91bb5fbb45cae361811f8864b9b63658962b461	["*"]	2025-05-04 09:35:57	\N	2025-04-24 08:28:53	2025-05-04 09:35:57
4	App\\Models\\User	12	authToken	3fba25910c7bb1490592d79c9e9df222b00c1df7b71fb6b48980a2f180bbe1db	["*"]	\N	\N	2025-05-05 20:22:36	2025-05-05 20:22:36
5	App\\Models\\User	12	authToken	507183e1c8b58623d6343f5a5f66606aac0f1067185808ccfc26cbde399ca5dc	["*"]	\N	\N	2025-05-06 10:27:31	2025-05-06 10:27:31
6	App\\Models\\User	12	authToken	893cfe449bf43f4e4ae3aacd5b2bd01ea7073fcd0708241e6635ec907f454985	["*"]	\N	\N	2025-05-06 11:31:17	2025-05-06 11:31:17
7	App\\Models\\User	12	authToken	6cf3d9ccbe9a6ca0cd5f3d67cac01b8ec64eee669c67812ec757c6394da48a43	["*"]	\N	\N	2025-05-06 12:24:36	2025-05-06 12:24:36
8	App\\Models\\User	12	authToken	48e826e804b1fd63d9ed303141e0dbeab787923b2ab47d372b68418bb601ce70	["*"]	\N	\N	2025-05-06 12:37:43	2025-05-06 12:37:43
9	App\\Models\\User	12	authToken	1452f6b4aeadbc8c721118d08a461fe7c0be13b9b978dbad02a5fc544a67b1d9	["*"]	\N	\N	2025-05-06 12:38:55	2025-05-06 12:38:55
10	App\\Models\\User	12	authToken	3e400f039f60345f4bc11ae8f194f006be826fa1896e899ecdcdb28cd560b233	["*"]	\N	\N	2025-05-06 12:45:28	2025-05-06 12:45:28
11	App\\Models\\User	12	authToken	167c9c9d66d9c6e6bd170eeae8c4012e2a9653bcc8db1e988f7ccb64db808211	["*"]	\N	\N	2025-05-06 13:12:08	2025-05-06 13:12:08
12	App\\Models\\User	12	authToken	e07b12a8a5a7d907f9129874fb87f1d7a79783eef40f9bd637e9a7b803ebeb48	["*"]	\N	\N	2025-05-09 19:53:50	2025-05-09 19:53:50
13	App\\Models\\User	12	authToken	3dad151365d8bcd0eaf04bd638664f884e19a212f6339485104516ceee6c07b2	["*"]	\N	\N	2025-05-09 20:07:51	2025-05-09 20:07:51
14	App\\Models\\User	12	authToken	c3599e087300e9c9cb4a753667e1bc28655b5d4effb37636db0d7a2c8e24180f	["*"]	\N	\N	2025-05-09 20:08:31	2025-05-09 20:08:31
15	App\\Models\\User	12	authToken	8b05bcaba00da61b59b6e7a14d95266544df1fd4cd4d0eb156204529bfffd0c6	["*"]	\N	\N	2025-05-09 20:13:57	2025-05-09 20:13:57
16	App\\Models\\User	12	authToken	dc9540ea0e23ba7e77db3ee3d953c27fe8e33ace83965f9bbeb17e251a60089c	["*"]	\N	\N	2025-05-09 20:18:52	2025-05-09 20:18:52
17	App\\Models\\User	12	authToken	88a6321e9bba4ceea5c7a2c34ffbca8c4f25464bcfa53ea0da04f0e3797b2598	["*"]	\N	\N	2025-05-11 07:14:42	2025-05-11 07:14:42
18	App\\Models\\User	13	authToken	aa1dbe52ebc30a1530b6c46cf48d1824b6892f00923183edfc1826e5b3c9870e	["*"]	\N	\N	2025-05-14 13:56:17	2025-05-14 13:56:17
20	App\\Models\\User	14	authToken	30fa41eb54a3556897f78ea93c3965cc6a1605526c586bd780dd4ae97fad01ee	["*"]	\N	\N	2025-05-19 09:35:04	2025-05-19 09:35:04
27	App\\Models\\User	1	authToken	22e365e2471f6ea654384949222b456628caa05afe0cb3f84d164b25cd8a61c9	["*"]	\N	\N	2025-06-16 21:57:51	2025-06-16 21:57:51
28	App\\Models\\User	2	authToken	795a940a079cc570e0ba47bd17e3575905c7e52be390d5c67796a451c2b15ff0	["*"]	\N	\N	2025-06-17 07:35:21	2025-06-17 07:35:21
29	App\\Models\\User	2	authToken	1340adf9948b0933097ff9bb98c1d9587e7496a934c4dea8da2843c0ca35e15b	["*"]	\N	\N	2025-06-17 10:09:28	2025-06-17 10:09:28
39	App\\Models\\User	14	authToken	678c7d83df0832650b9a13640ce7ce866c8cf8c265118e90e81a12e0520a3183	["*"]	\N	\N	2025-06-21 15:46:01	2025-06-21 15:46:01
40	App\\Models\\User	12	authToken	21b6caa5d2cabcfb9e5ef75d57cb81766e1b1e590cb87f32734357c4172baad4	["*"]	\N	\N	2025-06-22 08:34:29	2025-06-22 08:34:29
42	App\\Models\\User	1	authToken	8e012e0f5c08b7723fa7783d6df71e6c5cd22dc8ea2c7486a450d8ce638295da	["*"]	\N	\N	2025-06-23 13:19:10	2025-06-23 13:19:10
43	App\\Models\\User	1	authToken	314f89aba992f5a4a419447c9820a931f3ad3ab4f047727f97f4a5b6bfc74f59	["*"]	\N	\N	2025-06-25 11:48:14	2025-06-25 11:48:14
45	App\\Models\\Admin	1	admin-token	c2aa5e46618c9dcb574154070f5e7a5b57743a8a7343b01ce12a266893a1c723	["*"]	\N	\N	2025-07-01 03:07:04	2025-07-01 03:07:04
46	App\\Models\\Admin	1	admin-token	89ee219562a176beb2e466089b5823b78e22b0489f42ba79abc494d85622fa90	["*"]	\N	\N	2025-07-01 03:09:45	2025-07-01 03:09:45
47	App\\Models\\Admin	1	admin-token	36b172b9c6fb6c839395ed78428f3639b62bc2f86b54bcfaa87a588f1f9f5cc7	["*"]	\N	\N	2025-07-02 09:15:32	2025-07-02 09:15:32
48	App\\Models\\Admin	1	admin-token	7b9069f99ea11de7670c7550bf0da6a54dd4687a7e6efc272ce6806ad87fc8d0	["*"]	\N	\N	2025-07-02 09:42:16	2025-07-02 09:42:16
49	App\\Models\\Admin	1	admin-token	00c9db733d5eb5bf867257c70dd227b626d0e08e098c44bb2558cfcf9bc7e8c6	["*"]	\N	\N	2025-07-02 09:52:42	2025-07-02 09:52:42
63	App\\Models\\User	9	authToken	53fbe3055f4625c7dbf9d412245e3a1642c98b70d15cd8d17182f008da37e3ba	["*"]	2025-07-08 09:59:55	\N	2025-07-07 13:22:45	2025-07-08 09:59:55
65	App\\Models\\User	17	authToken	9cf08dead5b43b609288fe8e53cffec6b8dbbe141869d88fd96bde83d2ebd7bb	["*"]	\N	\N	2025-07-08 10:10:14	2025-07-08 10:10:14
55	App\\Models\\User	1	authToken	63e9f8c23e74d54dac6c1ed575e10b8bce0551ed004651378844c3172c378a68	["*"]	2025-07-04 17:11:18	\N	2025-07-04 14:59:23	2025-07-04 17:11:18
50	App\\Models\\Admin	1	admin-token	d4828fb5b27cedeb582f01273a039a4d3d8bbca939083a6097a13b06af289d9d	["*"]	\N	\N	2025-07-02 11:24:12	2025-07-02 11:24:12
51	App\\Models\\Admin	1	admin-token	192d62d008943ba339d0492958f17904d40cb56363aa6a69ad87c0af0d9f1331	["*"]	\N	\N	2025-07-02 11:24:32	2025-07-02 11:24:32
56	App\\Models\\Admin	1	admin-token	6983897d6b22c60c6e8275e7d4dbcd3fc7773269106fbbd8c9057a8780ae6dd0	["*"]	\N	\N	2025-07-05 00:13:33	2025-07-05 00:13:33
57	App\\Models\\User	16	authToken	080458d600a3f88cbe5b75fc8f094c0b119063acc5d4f1b7ff0bb9b6dd57ea9e	["*"]	\N	\N	2025-07-06 18:58:24	2025-07-06 18:58:24
80	App\\Models\\User	10	authToken	18371c7750907d1d37569722bab982776a09755c0f3824fe1402d1ab8f9b5a65	["*"]	2025-07-11 20:36:48	\N	2025-07-11 20:14:27	2025-07-11 20:36:48
44	App\\Models\\User	1	authToken	ce9f4bf88709546a2f6128a2d25ea5a3b9412552d0fc8741a2f0407ae2c3681b	["*"]	2025-07-04 08:51:17	\N	2025-06-25 15:00:32	2025-07-04 08:51:17
83	App\\Models\\User	3	authToken	8bb60002bf9411e0cf50d5bfd3d904bd482b7005a3e05676ac5907f63ccc9972	["*"]	\N	\N	2025-07-14 04:58:08	2025-07-14 04:58:08
81	App\\Models\\User	1	authToken	4529a741f573f8ae6b45bd9118d2ab1607b457856f7ea277f27eab7fac55294f	["*"]	2025-07-14 04:37:31	\N	2025-07-11 20:37:06	2025-07-14 04:37:31
74	App\\Models\\User	15	authToken	466663733be5c85303c9837a516dfe7db284508eded2ee373a6d5046d0a9e566	["*"]	2025-07-10 22:37:52	\N	2025-07-10 22:09:30	2025-07-10 22:37:52
58	App\\Models\\User	1	authToken	0e05b57265fcd91a58f4e37fa60eda359cd0995c320e705fffd0d8cc8a396f45	["*"]	2025-07-06 21:15:04	\N	2025-07-06 20:02:21	2025-07-06 21:15:04
59	App\\Models\\User	1	authToken	605222e9f9b29333166ddc3ca97d30d87c89695c99521f155e3127929cf835de	["*"]	\N	\N	2025-07-07 12:35:21	2025-07-07 12:35:21
60	App\\Models\\Admin	1	admin-token	c5b51ecd054272d338611612f50a7233a77e43a62f604b1e44793e385028cc50	["*"]	\N	\N	2025-07-07 12:41:09	2025-07-07 12:41:09
61	App\\Models\\Admin	1	admin-token	c3f766de771b6327560bb8497ab22d8d5d833d9fbf5309e1c5f6ec791a966805	["*"]	\N	\N	2025-07-07 12:41:28	2025-07-07 12:41:28
62	App\\Models\\Admin	1	admin-token	99713232fda6ca07e1250e5d66cfd3a0a5769f73f762865212dd1ca0b4655807	["*"]	\N	\N	2025-07-07 12:53:03	2025-07-07 12:53:03
75	App\\Models\\User	17	authToken	604e3e85128813a96b4c00a53758df600dd5ab1f5a8b37d1b02eeaa453d40284	["*"]	2025-07-10 22:54:03	\N	2025-07-10 22:50:27	2025-07-10 22:54:03
52	App\\Models\\User	1	authToken	62943d30cc39515f0b4430dbc29e3925bce55c6817446fe1bec716d57716bc87	["*"]	2025-07-04 09:40:29	\N	2025-07-04 08:54:46	2025-07-04 09:40:29
53	App\\Models\\User	15	authToken	6c284c3bca41875ca07d65d6b4dd22369171294b7d12d11cded3ac56b7087ec4	["*"]	\N	\N	2025-07-04 14:53:17	2025-07-04 14:53:17
54	App\\Models\\User	15	authToken	c3e19607008447ae97a966d432eb6096d0d11cc2689e009404494bf53a4e4236	["*"]	\N	\N	2025-07-04 14:53:24	2025-07-04 14:53:24
77	App\\Models\\User	1	authToken	1acc2b650325c974176cd5345d2df1a632217be94f8bcea3e3884b21df8a178b	["*"]	2025-07-11 11:11:39	\N	2025-07-11 10:14:06	2025-07-11 11:11:39
66	App\\Models\\User	3	authToken	8b4ba1b18c144f34f4f2819984cac352a9ee655198504c58be2f9363e749843e	["*"]	2025-07-08 14:13:28	\N	2025-07-08 13:14:33	2025-07-08 14:13:28
64	App\\Models\\Admin	1	admin-token	54bb359acef7e6516cf101b06f7514b7035fdb6b50474ac51d562576436af323	["*"]	\N	\N	2025-07-08 05:16:38	2025-07-08 05:16:38
67	App\\Models\\Admin	1	admin-token	74be9ee249951ad6c0396c708b06c4d19e99a41b3c2301237e5b9f0b03d36960	["*"]	\N	\N	2025-07-09 16:45:00	2025-07-09 16:45:00
68	App\\Models\\User	18	authToken	66784f2cb3740b7ad5be0669fdf05a77124f42bfe4adecb06960bd7a80530414	["*"]	\N	\N	2025-07-09 17:33:25	2025-07-09 17:33:25
69	App\\Models\\User	18	authToken	b0a2ae294fd1c229d69dd6ce532d613cda63d71b3442bc20fa431f21fdb75351	["*"]	\N	\N	2025-07-09 17:33:37	2025-07-09 17:33:37
70	App\\Models\\User	1	authToken	b3958294bf0420bfc8e3560aa48075c8a160ad95ee73be7e35f62d74ff05851a	["*"]	\N	\N	2025-07-09 17:36:28	2025-07-09 17:36:28
71	App\\Models\\User	1	authToken	c85d723a61c68d8d9b7afe5118b95d4127f7066a245f8b5704023ed5e9615a7f	["*"]	\N	\N	2025-07-09 17:37:32	2025-07-09 17:37:32
72	App\\Models\\User	17	authToken	72755a2cec2cf70db93e3b4973a14dc5054d9a81848b7f7be94788cd8e324262	["*"]	\N	\N	2025-07-10 20:33:03	2025-07-10 20:33:03
76	App\\Models\\User	1	authToken	6e93a07db39718b2c9d045fd7b8a196a431b13f8483a9e1f6b1f30b53b1359aa	["*"]	2025-07-11 10:03:15	\N	2025-07-11 09:59:08	2025-07-11 10:03:15
73	App\\Models\\User	15	authToken	deed8067e48ff7b5a6bc4affadcba08db621a56b11e5cbad97039df344a3a476	["*"]	2025-07-10 22:01:29	\N	2025-07-10 20:38:18	2025-07-10 22:01:29
78	App\\Models\\User	14	authToken	7bd5b18ad332b782b0a5df8956820579b8d0ce843b2bd65bc60cebd21d008f36	["*"]	2025-07-11 11:54:12	\N	2025-07-11 11:14:59	2025-07-11 11:54:12
79	App\\Models\\Admin	1	admin-token	970d8898a69236c26e2a936b4f7ed3ad2c1985ca1dfa53caa11f91ee0c753ec2	["*"]	\N	\N	2025-07-11 19:17:15	2025-07-11 19:17:15
82	App\\Models\\User	3	authToken	ac63f3e04eaae26783e853d5394bb46e8d3e24ea5dca74fe4718f037756fa624	["*"]	2025-07-14 04:46:53	\N	2025-07-14 04:46:29	2025-07-14 04:46:53
84	App\\Models\\User	3	authToken	8d895ee6e0a3900215789c0e3246b90d5d8ed7601caebd58dc83773702f9cef7	["*"]	2025-07-14 05:07:02	\N	2025-07-14 05:00:43	2025-07-14 05:07:02
85	App\\Models\\Admin	1	admin-token	681bf65280576cdd6af61c6ac7f5c8e78e5f5a03024ee11e8e99bd3e3ef958a5	["*"]	\N	\N	2025-07-14 05:08:32	2025-07-14 05:08:32
86	App\\Models\\User	3	authToken	a9f17631522c90006bba9b58f76d462a7f678de15848c976ab89cec2f3c7208d	["*"]	2025-07-22 00:51:29	\N	2025-07-14 05:12:27	2025-07-22 00:51:29
88	App\\Models\\User	3	authToken	31a9e8bbca0bcae6d084117dd720138f251865131154ee79fb0fa3705b4ad302	["*"]	\N	\N	2025-07-22 14:33:53	2025-07-22 14:33:53
87	App\\Models\\Admin	1	admin-token	803d83ddb783a24fca74ad4db555723807190d395ccba7548f458f5390da52d5	["*"]	\N	\N	2025-07-14 05:18:35	2025-07-14 05:18:35
89	App\\Models\\User	19	authToken	bf61e1c8b193c9589facd0fbcf681aeb384675345edf91a9c92f9b43f5f98916	["*"]	\N	\N	2025-07-22 14:37:57	2025-07-22 14:37:57
90	App\\Models\\User	19	authToken	38ea6145e80ca2caab99b4f0f29ef4b07f9953b0447a4ab4a8f31cdf827460de	["*"]	\N	\N	2025-07-22 14:38:48	2025-07-22 14:38:48
91	App\\Models\\User	10	authToken	6a535cce4aac80374defa6bd3afc7df4001c2a97f5b8fd6dfb3e40302ceaa4de	["*"]	\N	\N	2025-07-23 02:37:19	2025-07-23 02:37:19
92	App\\Models\\User	13	authToken	a22ac1939a50096d6a300c876c09ba60f7b39deeac1cb5626e1728697c94d97b	["*"]	\N	\N	2025-07-23 02:46:01	2025-07-23 02:46:01
93	App\\Models\\User	13	authToken	b6dff815b43e7b442482624b0ef9f47f7cf98574cdb0d5b105a20abb498eed46	["*"]	\N	\N	2025-07-23 03:22:33	2025-07-23 03:22:33
\.


--
-- TOC entry 5057 (class 0 OID 16584)
-- Dependencies: 240
-- Data for Name: reviews; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.reviews (id, user_id, room_id, rating, comment, created_at, booking_id) FROM stdin;
13	1	2	5	phòng oke	2025-06-20 17:02:13.099114	80
14	1	21	1	Không có nhận xét.	2025-07-04 16:04:43.581634	49
15	1	41	5	Không có nhận xét.	2025-07-07 04:11:08.194725	91
19	3	4	5	phòng tốt	2025-07-14 12:21:50.024328	104
\.


--
-- TOC entry 5059 (class 0 OID 16592)
-- Dependencies: 242
-- Data for Name: rooms; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.rooms (id, room_number, room_type, price, status, description, created_at, deleted_at, capacity) FROM stdin;
11	201	Double	800000.00	available	Spacious double room, ideal for couples.	2025-04-05 13:30:23.017322	\N	4
22	302	Suite	2500000.00	available	Our Single Room is perfect for solo travelers seeking comfort and privacy.	2025-04-05 13:30:23.017322	\N	2
25	402	Suite	2500000.00	available	Premium suite with sea view, bathtub and large balcony.	2025-04-05 13:30:23.017322	\N	2
13	203	Double	800000.00	available	Fully equipped double room at a reasonable price.	2025-04-05 13:30:23.017322	\N	4
39	403	Suite	500000.00	available	Phòng tổng thống	2025-06-19 05:07:52.463973	2025-06-26 06:08:18	2
41	404	Suite	500000.00	available	Phòng nô lệ	2025-06-19 05:31:27.320856	2025-07-07 13:30:26	2
14	204	Double	800000.00	available	Comfortable double room with soft bed.	2025-04-05 13:30:23.017322	\N	4
15	205	Double	950000.00	available	Double room with large windows, fantastic sea view.	2025-04-05 13:30:23.017322	\N	4
17	207	Double	950000.00	available	Double room with sea view, spacious and ideal for couples.	2025-04-05 13:30:23.017322	\N	4
18	208	Double	950000.00	available	Double room with sea view and large windows.	2025-04-05 13:30:23.017322	\N	4
20	210	Double	950000.00	available	Modern double room with full facilities and sea view.	2025-04-05 13:30:23.017322	\N	4
4	104	Single	500000.00	available	Cozy single room with comfortable bed.	2025-04-05 13:30:23.017322	\N	2
12	202	Double	800000.00	available	Double room with balcony and nice view.	2025-04-05 13:30:23.017322	\N	4
16	206	Double	800000.00	available	Double room near the garden.	2025-04-05 13:30:23.017322	\N	4
5	105	Single	650000.00	available	Single room with a sea view, peaceful and comfortable.	2025-04-05 13:30:23.017322	\N	2
8	108	Single	650000.00	available	Quiet single room with sea view.	2025-04-05 13:30:23.017322	\N	2
9	109	Single	500000.00	available	Standard single room for business trip.	2025-04-05 13:30:23.017322	\N	2
2	102	Single	500000.00	available	Single room with city view, quiet space.	2025-04-05 13:30:23.017322	\N	2
3	103	Single	500000.00	available	Budget-friendly single room, suitable for solo travelers.	2025-04-05 13:30:23.017322	\N	2
43	405	Suite	500000.00	available	Phòng	2025-06-19 05:44:16.224266	2025-06-18 23:26:41	2
24	401	Suite	1500000.00	available	Luxury suite with living area and kitchen	2025-04-05 13:30:23.017322	\N	2
23	303	Suite	1500000.00	available	Our Single Room is perfect for solo travelers seeking comfort and privacy.	2025-04-05 13:30:23.017322	\N	2
6	106	Single	500000.00	available	Our Single Room is perfect for solo travelers seeking comfort and privacy.	2025-04-05 13:30:23.017322	\N	2
7	107	Single	650000.00	available	Our Single Room is perfect for solo travelers seeking comfort and privacy.	2025-04-05 13:30:23.017322	\N	2
10	110	Single	650000.00	available	Our Single Room is perfect for solo travelers seeking comfort and privacy.	2025-04-05 13:30:23.017322	\N	2
21	301	Suite	1500000.00	available	Our Single Room is perfect for solo travelers seeking comfort and privacy.	2025-04-05 13:30:23.017322	\N	2
\.


--
-- TOC entry 5061 (class 0 OID 16601)
-- Dependencies: 244
-- Data for Name: service_orders; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.service_orders (id, booking_id, service_id, quantity, total_price, order_date, deleted_at) FROM stdin;
15	76	1	1	100000.00	2025-06-18	2025-06-18 17:27:29
20	82	1	1	100000.00	2025-06-20	2025-06-20 09:43:05
17	81	1	1	100000.00	2025-06-20	2025-06-20 09:43:10
18	81	3	1	180000.00	2025-06-20	2025-06-20 09:43:10
19	81	2	1	150000.00	2025-06-20	2025-06-20 09:43:10
16	80	1	1	100000.00	2025-06-20	2025-06-20 10:03:09
21	91	1	1	100000.00	2025-06-26	\N
22	103	2	1	150000.00	2025-07-14	\N
14	75	1	1	100000.00	2025-06-18	2025-07-14 05:11:25
23	104	2	1	150000.00	2025-07-14	\N
\.


--
-- TOC entry 5063 (class 0 OID 16607)
-- Dependencies: 246
-- Data for Name: services; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.services (id, name, price, description, deleted_at) FROM stdin;
2	Shuttle Service	150000.00	Transportation service from and to the hotel, available upon request.	\N
3	Fitness & Swimming	180000.00	Access to both the swimming pool and the gym, providing a complete fitness experience.	\N
1	Breakfast	100000.00	A variety of breakfast options including continental, local dishes, and beverages	\N
\.


--
-- TOC entry 5065 (class 0 OID 16613)
-- Dependencies: 248
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, name, email, password, phone, created_at, updated_at, deleted_at) FROM stdin;
11	Giang Sơn	sonn@gmail.com	$2y$12$dmwd3aa7KjU1O/Rk8yw8j.VeqPFrPKBu4HQCXzEwpc/1yONq0zPmm	\N	2025-04-24 15:28:53.509158	\N	\N
1	John Doe	john.doe@example.com	$2y$12$uQUOYsjSqGgfQ9ciJKs2uOzyccJn/R6eJGemVD/MwrYdSBo3IaRaC	0377492876	2025-04-06 16:04:08.969773	2025-07-11 16:59:00.601358	\N
14	giang sơn	nguyengiangson194203@gmail.com	$2y$12$DxjsqUHPjFpYf0yWTuppW.2tP7Do2MKTnMqZR7qzmYjnuJD/rxBXG	0945687245	2025-05-14 21:07:35.073337	2025-07-11 18:14:55.948883	\N
3	Nguyen Van A	vana@gmail.com	$2y$12$xaGxjzXltA1I1eQbkxV9SOvAvEkThg/s68ch2F.hxrihX1OEIK96.	0945612387	2025-04-21 13:12:33.891157	2025-07-14 11:39:31.529731	\N
6	Nguyen Giang A	va@gmail.com	$2y$12$N.Mc0Dx4rNWAzgu6Qg7nNuaqulXJqdVHe3dqlS3v4vnXUBfaFf.Om	\N	2025-04-21 13:38:11.206907	2025-06-19 06:39:11.717702	2025-06-18 23:39:11
19	thiên châu	thienchau@gmail.com	$2y$12$Z6VroTsfkD24oGIhLkAYEe5hwCcsXtzsz0lmqQb0qyXxG6SKIaoQq	0986574351	2025-07-22 21:37:57.784549	\N	\N
10	Giang Sơn	son@gmail.com	$2y$12$1tcRdBjJrwKgQnQZ5ykj7Oe72TxsjaSMvyOQO6x8tpjUQNfFnxcn2	0955555555	2025-04-24 14:44:09.231214	2025-07-23 09:36:25.762984	\N
12	Giang Sơn	sonn1@gmail.com	$2y$12$Xp9SALp/Je6pIYp6YobY0uAqMTrr7uMXYKQFcjS7GqGmyg413dRzW	\N	2025-05-06 03:22:36.653538	2025-06-22 15:34:11.314434	\N
15	aaaa	giangson111@gmail.com	$2y$12$Bqi79SPNNBBuMfLg5wmX0.Px3Wtb2y0GQd8At8rImfgKm2fTKq3Aq	0377492811	2025-07-04 21:53:17.79165	\N	\N
16	SET 8	giangsonn@gmail.com	$2y$12$jhEdZeg7rJP5z8MHJGIsZeqJzMimejTJBU5JNJ9a82yG3mTVba1k2	0912345678	2025-07-07 01:58:24.82145	\N	\N
7	Nguyen Giang A	vai@gmail.com	$2y$12$IChm7Fju5JCISaD51uMN4e6fGOIt4Nbr./hPh0jjnp35N18kZvb9a	0955555558	2025-04-21 13:57:11.659513	2025-07-23 09:36:37.558523	\N
2	Jane Smith	jane.smith@example.com	$2y$12$kkXZuue0Mw/t52mx4CdKAub57iLR4l41AYDzn99KsMLbLgL/JJ20G	0377492879	2025-04-06 16:04:08.969773	2025-07-08 11:28:36.152893	\N
4	Nguyen Van B	vaana@gmail.com	$2y$12$pAzkyc0MppNmvd9AIdww2.X1HttLKZ2DBSwvFnpycaTX5IuyYl.G.	0956666666	2025-04-21 13:28:46.148372	2025-07-23 09:36:47.951662	\N
13	Nguyễn Giang Sơn	nguyengiangson190444@gmail.com	$2y$12$2k/NtLTlAMfczDpfFfwny..wwS2xqFQ37jOfTFL/wLgaaXQlX.Vyy	0945856781	2025-05-14 20:56:17.804738	2025-07-23 09:45:46.29946	\N
9	Giang Sơn	ao@gmail.com	$2y$12$4djJKxwF7ae7FUJuK8pr9uGbExwoxhsYurjpWkuEvydigtINW45bW	0377492875	2025-04-21 14:59:11.659611	2025-07-08 12:33:29.794226	\N
17	son	1@gmail.com	$2y$12$6dOI5qOpikAiSlxuTjt95.Adt3iB.UTGRADHa24hh6oF8G7rShLCW	0111111111	2025-07-08 17:10:14.129932	\N	\N
18	giang sơn	giangson12@gmail.com	$2y$12$wgYPa65NCC6zN9yNFh83eeM9VhIB3jJiC2mRmHsMsliMuSK7f/KxK	0377492872	2025-07-10 00:33:25.453582	\N	\N
\.


--
-- TOC entry 5098 (class 0 OID 0)
-- Dependencies: 219
-- Name: admins_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.admins_id_seq', 4, true);


--
-- TOC entry 5099 (class 0 OID 0)
-- Dependencies: 221
-- Name: bookings_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.bookings_id_seq', 104, true);


--
-- TOC entry 5100 (class 0 OID 0)
-- Dependencies: 223
-- Name: contacts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.contacts_id_seq', 14, true);


--
-- TOC entry 5101 (class 0 OID 0)
-- Dependencies: 225
-- Name: conversations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.conversations_id_seq', 33, true);


--
-- TOC entry 5102 (class 0 OID 0)
-- Dependencies: 227
-- Name: discounts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.discounts_id_seq', 13, true);


--
-- TOC entry 5103 (class 0 OID 0)
-- Dependencies: 229
-- Name: faq_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.faq_id_seq', 25, true);


--
-- TOC entry 5104 (class 0 OID 0)
-- Dependencies: 254
-- Name: hotel_info_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.hotel_info_id_seq', 26, true);


--
-- TOC entry 5105 (class 0 OID 0)
-- Dependencies: 231
-- Name: images_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.images_id_seq', 105, true);


--
-- TOC entry 5106 (class 0 OID 0)
-- Dependencies: 233
-- Name: invoice_items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.invoice_items_id_seq', 16, true);


--
-- TOC entry 5107 (class 0 OID 0)
-- Dependencies: 235
-- Name: invoices_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.invoices_id_seq', 21, true);


--
-- TOC entry 5108 (class 0 OID 0)
-- Dependencies: 237
-- Name: messages_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.messages_id_seq', 59, true);


--
-- TOC entry 5109 (class 0 OID 0)
-- Dependencies: 250
-- Name: migrations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.migrations_id_seq', 4, true);


--
-- TOC entry 5110 (class 0 OID 0)
-- Dependencies: 239
-- Name: payments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.payments_id_seq', 73, true);


--
-- TOC entry 5111 (class 0 OID 0)
-- Dependencies: 252
-- Name: personal_access_tokens_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.personal_access_tokens_id_seq', 93, true);


--
-- TOC entry 5112 (class 0 OID 0)
-- Dependencies: 241
-- Name: reviews_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.reviews_id_seq', 19, true);


--
-- TOC entry 5113 (class 0 OID 0)
-- Dependencies: 243
-- Name: rooms_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.rooms_id_seq', 48, true);


--
-- TOC entry 5114 (class 0 OID 0)
-- Dependencies: 245
-- Name: service_orders_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.service_orders_id_seq', 23, true);


--
-- TOC entry 5115 (class 0 OID 0)
-- Dependencies: 247
-- Name: services_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.services_id_seq', 10, true);


--
-- TOC entry 5116 (class 0 OID 0)
-- Dependencies: 249
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_id_seq', 19, true);


--
-- TOC entry 4822 (class 2606 OID 16638)
-- Name: admins admins_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.admins
    ADD CONSTRAINT admins_email_key UNIQUE (email);


--
-- TOC entry 4824 (class 2606 OID 16640)
-- Name: admins admins_phone_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.admins
    ADD CONSTRAINT admins_phone_key UNIQUE (phone);


--
-- TOC entry 4826 (class 2606 OID 16642)
-- Name: admins admins_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.admins
    ADD CONSTRAINT admins_pkey PRIMARY KEY (id);


--
-- TOC entry 4828 (class 2606 OID 16644)
-- Name: bookings bookings_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bookings
    ADD CONSTRAINT bookings_pkey PRIMARY KEY (id);


--
-- TOC entry 4830 (class 2606 OID 16646)
-- Name: contacts contacts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.contacts
    ADD CONSTRAINT contacts_pkey PRIMARY KEY (id);


--
-- TOC entry 4832 (class 2606 OID 16648)
-- Name: conversations conversations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.conversations
    ADD CONSTRAINT conversations_pkey PRIMARY KEY (id);


--
-- TOC entry 4834 (class 2606 OID 16650)
-- Name: discounts discounts_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.discounts
    ADD CONSTRAINT discounts_code_key UNIQUE (code);


--
-- TOC entry 4836 (class 2606 OID 16652)
-- Name: discounts discounts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.discounts
    ADD CONSTRAINT discounts_pkey PRIMARY KEY (id);


--
-- TOC entry 4838 (class 2606 OID 16656)
-- Name: faq faq_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.faq
    ADD CONSTRAINT faq_pkey PRIMARY KEY (id);


--
-- TOC entry 4873 (class 2606 OID 25028)
-- Name: hotel_info hotel_info_key_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hotel_info
    ADD CONSTRAINT hotel_info_key_key UNIQUE (key);


--
-- TOC entry 4875 (class 2606 OID 25026)
-- Name: hotel_info hotel_info_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hotel_info
    ADD CONSTRAINT hotel_info_pkey PRIMARY KEY (id);


--
-- TOC entry 4840 (class 2606 OID 16658)
-- Name: images images_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.images
    ADD CONSTRAINT images_pkey PRIMARY KEY (id);


--
-- TOC entry 4842 (class 2606 OID 16660)
-- Name: invoice_items invoice_items_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.invoice_items
    ADD CONSTRAINT invoice_items_pkey PRIMARY KEY (id);


--
-- TOC entry 4844 (class 2606 OID 16662)
-- Name: invoices invoices_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_pkey PRIMARY KEY (id);


--
-- TOC entry 4846 (class 2606 OID 16664)
-- Name: messages messages_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_pkey PRIMARY KEY (id);


--
-- TOC entry 4866 (class 2606 OID 16772)
-- Name: migrations migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migrations
    ADD CONSTRAINT migrations_pkey PRIMARY KEY (id);


--
-- TOC entry 4848 (class 2606 OID 16666)
-- Name: payments payments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_pkey PRIMARY KEY (id);


--
-- TOC entry 4868 (class 2606 OID 16800)
-- Name: personal_access_tokens personal_access_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.personal_access_tokens
    ADD CONSTRAINT personal_access_tokens_pkey PRIMARY KEY (id);


--
-- TOC entry 4870 (class 2606 OID 16803)
-- Name: personal_access_tokens personal_access_tokens_token_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.personal_access_tokens
    ADD CONSTRAINT personal_access_tokens_token_unique UNIQUE (token);


--
-- TOC entry 4850 (class 2606 OID 16668)
-- Name: reviews reviews_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reviews
    ADD CONSTRAINT reviews_pkey PRIMARY KEY (id);


--
-- TOC entry 4852 (class 2606 OID 16670)
-- Name: rooms rooms_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rooms
    ADD CONSTRAINT rooms_pkey PRIMARY KEY (id);


--
-- TOC entry 4854 (class 2606 OID 16672)
-- Name: rooms rooms_room_number_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rooms
    ADD CONSTRAINT rooms_room_number_key UNIQUE (room_number);


--
-- TOC entry 4856 (class 2606 OID 16674)
-- Name: service_orders service_orders_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.service_orders
    ADD CONSTRAINT service_orders_pkey PRIMARY KEY (id);


--
-- TOC entry 4858 (class 2606 OID 16676)
-- Name: services services_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.services
    ADD CONSTRAINT services_pkey PRIMARY KEY (id);


--
-- TOC entry 4860 (class 2606 OID 16678)
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- TOC entry 4862 (class 2606 OID 16680)
-- Name: users users_phone_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_phone_key UNIQUE (phone);


--
-- TOC entry 4864 (class 2606 OID 16682)
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- TOC entry 4871 (class 1259 OID 16801)
-- Name: personal_access_tokens_tokenable_type_tokenable_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX personal_access_tokens_tokenable_type_tokenable_id_index ON public.personal_access_tokens USING btree (tokenable_type, tokenable_id);


--
-- TOC entry 4889 (class 2620 OID 16765)
-- Name: users update_users_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON public.users FOR EACH ROW EXECUTE FUNCTION public.update_timestamp();


--
-- TOC entry 4876 (class 2606 OID 16683)
-- Name: bookings bookings_room_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bookings
    ADD CONSTRAINT bookings_room_id_fkey FOREIGN KEY (room_id) REFERENCES public.rooms(id) ON DELETE CASCADE;


--
-- TOC entry 4877 (class 2606 OID 16688)
-- Name: bookings bookings_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bookings
    ADD CONSTRAINT bookings_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- TOC entry 4878 (class 2606 OID 16693)
-- Name: conversations conversations_agent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.conversations
    ADD CONSTRAINT conversations_agent_id_fkey FOREIGN KEY (agent_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- TOC entry 4879 (class 2606 OID 16698)
-- Name: conversations conversations_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.conversations
    ADD CONSTRAINT conversations_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- TOC entry 4884 (class 2606 OID 16818)
-- Name: reviews fk_booking; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reviews
    ADD CONSTRAINT fk_booking FOREIGN KEY (booking_id) REFERENCES public.bookings(id) ON DELETE CASCADE;


--
-- TOC entry 4880 (class 2606 OID 16723)
-- Name: invoice_items invoice_items_invoice_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.invoice_items
    ADD CONSTRAINT invoice_items_invoice_id_fkey FOREIGN KEY (invoice_id) REFERENCES public.invoices(id) ON DELETE CASCADE;


--
-- TOC entry 4881 (class 2606 OID 16728)
-- Name: invoices invoices_booking_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_booking_id_fkey FOREIGN KEY (booking_id) REFERENCES public.bookings(id) ON DELETE CASCADE;


--
-- TOC entry 4882 (class 2606 OID 16733)
-- Name: messages messages_conversation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_conversation_id_fkey FOREIGN KEY (conversation_id) REFERENCES public.conversations(id) ON DELETE CASCADE;


--
-- TOC entry 4883 (class 2606 OID 16738)
-- Name: payments payments_booking_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_booking_id_fkey FOREIGN KEY (booking_id) REFERENCES public.bookings(id) ON DELETE CASCADE;


--
-- TOC entry 4885 (class 2606 OID 16743)
-- Name: reviews reviews_room_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reviews
    ADD CONSTRAINT reviews_room_id_fkey FOREIGN KEY (room_id) REFERENCES public.rooms(id) ON DELETE CASCADE;


--
-- TOC entry 4886 (class 2606 OID 16748)
-- Name: reviews reviews_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reviews
    ADD CONSTRAINT reviews_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- TOC entry 4887 (class 2606 OID 16753)
-- Name: service_orders service_orders_booking_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.service_orders
    ADD CONSTRAINT service_orders_booking_id_fkey FOREIGN KEY (booking_id) REFERENCES public.bookings(id) ON DELETE CASCADE;


--
-- TOC entry 4888 (class 2606 OID 16758)
-- Name: service_orders service_orders_service_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.service_orders
    ADD CONSTRAINT service_orders_service_id_fkey FOREIGN KEY (service_id) REFERENCES public.services(id) ON DELETE CASCADE;


-- Completed on 2025-07-27 15:08:38

--
-- PostgreSQL database dump complete
--

