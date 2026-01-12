--
-- PostgreSQL database dump
--

\restrict OmsIXOucjxB0glJSh0Rc8lIo74oosq2TnxVpWY7LXHzKRehhr2Mzyxe0BohY7f8

-- Dumped from database version 15.14 (Homebrew)
-- Dumped by pg_dump version 15.14 (Homebrew)

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
-- Name: public; Type: SCHEMA; Schema: -; Owner: ernestomonge
--

-- *not* creating schema, since initdb creates it


ALTER SCHEMA public OWNER TO ernestomonge;

--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: ernestomonge
--

COMMENT ON SCHEMA public IS '';


--
-- Name: EpicStatus; Type: TYPE; Schema: public; Owner: ernestomonge
--

CREATE TYPE public."EpicStatus" AS ENUM (
    'TODO',
    'IN_PROGRESS',
    'DONE',
    'CANCELLED'
);


ALTER TYPE public."EpicStatus" OWNER TO ernestomonge;

--
-- Name: InvitationStatus; Type: TYPE; Schema: public; Owner: ernestomonge
--

CREATE TYPE public."InvitationStatus" AS ENUM (
    'PENDING',
    'ACCEPTED',
    'DECLINED',
    'EXPIRED'
);


ALTER TYPE public."InvitationStatus" OWNER TO ernestomonge;

--
-- Name: NotificationType; Type: TYPE; Schema: public; Owner: ernestomonge
--

CREATE TYPE public."NotificationType" AS ENUM (
    'INFO',
    'SUCCESS',
    'WARNING',
    'ERROR',
    'TASK_ASSIGNED',
    'TASK_UPDATED',
    'PROJECT_UPDATED',
    'COMMENT_ADDED'
);


ALTER TYPE public."NotificationType" OWNER TO ernestomonge;

--
-- Name: ProjectRole; Type: TYPE; Schema: public; Owner: ernestomonge
--

CREATE TYPE public."ProjectRole" AS ENUM (
    'OWNER',
    'ADMIN',
    'MEMBER',
    'VIEWER'
);


ALTER TYPE public."ProjectRole" OWNER TO ernestomonge;

--
-- Name: SpaceRole; Type: TYPE; Schema: public; Owner: ernestomonge
--

CREATE TYPE public."SpaceRole" AS ENUM (
    'OWNER',
    'ADMIN',
    'MEMBER',
    'VIEWER'
);


ALTER TYPE public."SpaceRole" OWNER TO ernestomonge;

--
-- Name: SprintStatus; Type: TYPE; Schema: public; Owner: ernestomonge
--

CREATE TYPE public."SprintStatus" AS ENUM (
    'PLANNING',
    'ACTIVE',
    'COMPLETED'
);


ALTER TYPE public."SprintStatus" OWNER TO ernestomonge;

--
-- Name: TaskPriority; Type: TYPE; Schema: public; Owner: ernestomonge
--

CREATE TYPE public."TaskPriority" AS ENUM (
    'LOW',
    'MEDIUM',
    'HIGH',
    'URGENT'
);


ALTER TYPE public."TaskPriority" OWNER TO ernestomonge;

--
-- Name: TemplateCategory; Type: TYPE; Schema: public; Owner: ernestomonge
--

CREATE TYPE public."TemplateCategory" AS ENUM (
    'DESARROLLO_SOFTWARE',
    'MARKETING',
    'DISENO',
    'VENTAS',
    'OPERACIONES',
    'RECURSOS_HUMANOS',
    'GENERAL',
    'PERSONALIZADO'
);


ALTER TYPE public."TemplateCategory" OWNER TO ernestomonge;

--
-- Name: UserRole; Type: TYPE; Schema: public; Owner: ernestomonge
--

CREATE TYPE public."UserRole" AS ENUM (
    'ADMIN',
    'MEMBER',
    'READ_ONLY'
);


ALTER TYPE public."UserRole" OWNER TO ernestomonge;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: _prisma_migrations; Type: TABLE; Schema: public; Owner: ernestomonge
--

CREATE TABLE public._prisma_migrations (
    id character varying(36) NOT NULL,
    checksum character varying(64) NOT NULL,
    finished_at timestamp with time zone,
    migration_name character varying(255) NOT NULL,
    logs text,
    rolled_back_at timestamp with time zone,
    started_at timestamp with time zone DEFAULT now() NOT NULL,
    applied_steps_count integer DEFAULT 0 NOT NULL
);


ALTER TABLE public._prisma_migrations OWNER TO ernestomonge;

--
-- Name: accounts; Type: TABLE; Schema: public; Owner: ernestomonge
--

CREATE TABLE public.accounts (
    type text NOT NULL,
    provider text NOT NULL,
    "providerAccountId" text NOT NULL,
    refresh_token text,
    access_token text,
    expires_at integer,
    token_type text,
    scope text,
    id_token text,
    session_state text,
    id integer NOT NULL,
    "userId" integer NOT NULL
);


ALTER TABLE public.accounts OWNER TO ernestomonge;

--
-- Name: accounts_id_seq; Type: SEQUENCE; Schema: public; Owner: ernestomonge
--

CREATE SEQUENCE public.accounts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.accounts_id_seq OWNER TO ernestomonge;

--
-- Name: accounts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ernestomonge
--

ALTER SEQUENCE public.accounts_id_seq OWNED BY public.accounts.id;


--
-- Name: attachments; Type: TABLE; Schema: public; Owner: ernestomonge
--

CREATE TABLE public.attachments (
    filename text NOT NULL,
    url text NOT NULL,
    size integer,
    "mimeType" text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    id integer NOT NULL,
    "taskId" integer NOT NULL,
    "uploadedById" integer NOT NULL
);


ALTER TABLE public.attachments OWNER TO ernestomonge;

--
-- Name: attachments_id_seq; Type: SEQUENCE; Schema: public; Owner: ernestomonge
--

CREATE SEQUENCE public.attachments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.attachments_id_seq OWNER TO ernestomonge;

--
-- Name: attachments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ernestomonge
--

ALTER SEQUENCE public.attachments_id_seq OWNED BY public.attachments.id;


--
-- Name: audit_logs; Type: TABLE; Schema: public; Owner: ernestomonge
--

CREATE TABLE public.audit_logs (
    id integer NOT NULL,
    action text NOT NULL,
    field text,
    "oldValue" text,
    "newValue" text,
    details text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "taskId" integer,
    "userId" integer NOT NULL
);


ALTER TABLE public.audit_logs OWNER TO ernestomonge;

--
-- Name: audit_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: ernestomonge
--

CREATE SEQUENCE public.audit_logs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.audit_logs_id_seq OWNER TO ernestomonge;

--
-- Name: audit_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ernestomonge
--

ALTER SEQUENCE public.audit_logs_id_seq OWNED BY public.audit_logs.id;


--
-- Name: comments; Type: TABLE; Schema: public; Owner: ernestomonge
--

CREATE TABLE public.comments (
    content text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    id integer NOT NULL,
    "taskId" integer NOT NULL,
    "userId" integer NOT NULL
);


ALTER TABLE public.comments OWNER TO ernestomonge;

--
-- Name: comments_id_seq; Type: SEQUENCE; Schema: public; Owner: ernestomonge
--

CREATE SEQUENCE public.comments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.comments_id_seq OWNER TO ernestomonge;

--
-- Name: comments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ernestomonge
--

ALTER SEQUENCE public.comments_id_seq OWNED BY public.comments.id;


--
-- Name: epics; Type: TABLE; Schema: public; Owner: ernestomonge
--

CREATE TABLE public.epics (
    name text NOT NULL,
    description text,
    color text DEFAULT '#8B5CF6'::text,
    status public."EpicStatus" DEFAULT 'IN_PROGRESS'::public."EpicStatus" NOT NULL,
    "startDate" timestamp(3) without time zone,
    "targetDate" timestamp(3) without time zone,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    id integer NOT NULL,
    "projectId" integer NOT NULL
);


ALTER TABLE public.epics OWNER TO ernestomonge;

--
-- Name: epics_id_seq; Type: SEQUENCE; Schema: public; Owner: ernestomonge
--

CREATE SEQUENCE public.epics_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.epics_id_seq OWNER TO ernestomonge;

--
-- Name: epics_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ernestomonge
--

ALTER SEQUENCE public.epics_id_seq OWNED BY public.epics.id;


--
-- Name: invitations; Type: TABLE; Schema: public; Owner: ernestomonge
--

CREATE TABLE public.invitations (
    email text NOT NULL,
    role public."UserRole" DEFAULT 'MEMBER'::public."UserRole" NOT NULL,
    status public."InvitationStatus" DEFAULT 'PENDING'::public."InvitationStatus" NOT NULL,
    token text NOT NULL,
    "expiresAt" timestamp(3) without time zone NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    id integer NOT NULL,
    "organizationId" integer NOT NULL,
    "invitedById" integer NOT NULL
);


ALTER TABLE public.invitations OWNER TO ernestomonge;

--
-- Name: invitations_id_seq; Type: SEQUENCE; Schema: public; Owner: ernestomonge
--

CREATE SEQUENCE public.invitations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.invitations_id_seq OWNER TO ernestomonge;

--
-- Name: invitations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ernestomonge
--

ALTER SEQUENCE public.invitations_id_seq OWNED BY public.invitations.id;


--
-- Name: member_productivity; Type: TABLE; Schema: public; Owner: ernestomonge
--

CREATE TABLE public.member_productivity (
    id integer NOT NULL,
    date timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "tasksCompleted" integer DEFAULT 0 NOT NULL,
    "tasksInProgress" integer DEFAULT 0 NOT NULL,
    "tasksPending" integer DEFAULT 0 NOT NULL,
    "productivityScore" integer DEFAULT 0 NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "userId" integer NOT NULL,
    "projectId" integer
);


ALTER TABLE public.member_productivity OWNER TO ernestomonge;

--
-- Name: member_productivity_id_seq; Type: SEQUENCE; Schema: public; Owner: ernestomonge
--

CREATE SEQUENCE public.member_productivity_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.member_productivity_id_seq OWNER TO ernestomonge;

--
-- Name: member_productivity_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ernestomonge
--

ALTER SEQUENCE public.member_productivity_id_seq OWNED BY public.member_productivity.id;


--
-- Name: notifications; Type: TABLE; Schema: public; Owner: ernestomonge
--

CREATE TABLE public.notifications (
    title text NOT NULL,
    message text NOT NULL,
    type public."NotificationType" DEFAULT 'INFO'::public."NotificationType" NOT NULL,
    "isRead" boolean DEFAULT false NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    id integer NOT NULL,
    "userId" integer NOT NULL,
    "taskId" integer,
    "projectId" integer,
    link text
);


ALTER TABLE public.notifications OWNER TO ernestomonge;

--
-- Name: notifications_id_seq; Type: SEQUENCE; Schema: public; Owner: ernestomonge
--

CREATE SEQUENCE public.notifications_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.notifications_id_seq OWNER TO ernestomonge;

--
-- Name: notifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ernestomonge
--

ALTER SEQUENCE public.notifications_id_seq OWNED BY public.notifications.id;


--
-- Name: organizations; Type: TABLE; Schema: public; Owner: ernestomonge
--

CREATE TABLE public.organizations (
    name text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    id integer NOT NULL
);


ALTER TABLE public.organizations OWNER TO ernestomonge;

--
-- Name: organizations_id_seq; Type: SEQUENCE; Schema: public; Owner: ernestomonge
--

CREATE SEQUENCE public.organizations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.organizations_id_seq OWNER TO ernestomonge;

--
-- Name: organizations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ernestomonge
--

ALTER SEQUENCE public.organizations_id_seq OWNED BY public.organizations.id;


--
-- Name: password_reset_tokens; Type: TABLE; Schema: public; Owner: ernestomonge
--

CREATE TABLE public.password_reset_tokens (
    id integer NOT NULL,
    token text NOT NULL,
    email text NOT NULL,
    "expiresAt" timestamp(3) without time zone NOT NULL,
    used boolean DEFAULT false NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.password_reset_tokens OWNER TO ernestomonge;

--
-- Name: password_reset_tokens_id_seq; Type: SEQUENCE; Schema: public; Owner: ernestomonge
--

CREATE SEQUENCE public.password_reset_tokens_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.password_reset_tokens_id_seq OWNER TO ernestomonge;

--
-- Name: password_reset_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ernestomonge
--

ALTER SEQUENCE public.password_reset_tokens_id_seq OWNED BY public.password_reset_tokens.id;


--
-- Name: project_members; Type: TABLE; Schema: public; Owner: ernestomonge
--

CREATE TABLE public.project_members (
    role public."ProjectRole" DEFAULT 'MEMBER'::public."ProjectRole" NOT NULL,
    "joinedAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    id integer NOT NULL,
    "projectId" integer NOT NULL,
    "userId" integer NOT NULL
);


ALTER TABLE public.project_members OWNER TO ernestomonge;

--
-- Name: project_members_id_seq; Type: SEQUENCE; Schema: public; Owner: ernestomonge
--

CREATE SEQUENCE public.project_members_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.project_members_id_seq OWNER TO ernestomonge;

--
-- Name: project_members_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ernestomonge
--

ALTER SEQUENCE public.project_members_id_seq OWNED BY public.project_members.id;


--
-- Name: project_templates; Type: TABLE; Schema: public; Owner: ernestomonge
--

CREATE TABLE public.project_templates (
    id integer NOT NULL,
    name text NOT NULL,
    description text,
    category public."TemplateCategory" DEFAULT 'GENERAL'::public."TemplateCategory" NOT NULL,
    icon text DEFAULT 'Folder'::text,
    color text DEFAULT '#6B7280'::text,
    "isDefault" boolean DEFAULT false NOT NULL,
    "usageCount" integer DEFAULT 0 NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "organizationId" integer,
    "createdById" integer
);


ALTER TABLE public.project_templates OWNER TO ernestomonge;

--
-- Name: project_templates_id_seq; Type: SEQUENCE; Schema: public; Owner: ernestomonge
--

CREATE SEQUENCE public.project_templates_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.project_templates_id_seq OWNER TO ernestomonge;

--
-- Name: project_templates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ernestomonge
--

ALTER SEQUENCE public.project_templates_id_seq OWNED BY public.project_templates.id;


--
-- Name: projects; Type: TABLE; Schema: public; Owner: ernestomonge
--

CREATE TABLE public.projects (
    name text NOT NULL,
    description text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    id integer NOT NULL,
    "organizationId" integer,
    "spaceId" integer NOT NULL,
    "templateId" integer
);


ALTER TABLE public.projects OWNER TO ernestomonge;

--
-- Name: projects_id_seq; Type: SEQUENCE; Schema: public; Owner: ernestomonge
--

CREATE SEQUENCE public.projects_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.projects_id_seq OWNER TO ernestomonge;

--
-- Name: projects_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ernestomonge
--

ALTER SEQUENCE public.projects_id_seq OWNED BY public.projects.id;


--
-- Name: sessions; Type: TABLE; Schema: public; Owner: ernestomonge
--

CREATE TABLE public.sessions (
    "sessionToken" text NOT NULL,
    expires timestamp(3) without time zone NOT NULL,
    id integer NOT NULL,
    "userId" integer NOT NULL
);


ALTER TABLE public.sessions OWNER TO ernestomonge;

--
-- Name: sessions_id_seq; Type: SEQUENCE; Schema: public; Owner: ernestomonge
--

CREATE SEQUENCE public.sessions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sessions_id_seq OWNER TO ernestomonge;

--
-- Name: sessions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ernestomonge
--

ALTER SEQUENCE public.sessions_id_seq OWNED BY public.sessions.id;


--
-- Name: space_members; Type: TABLE; Schema: public; Owner: ernestomonge
--

CREATE TABLE public.space_members (
    role public."SpaceRole" DEFAULT 'MEMBER'::public."SpaceRole" NOT NULL,
    "joinedAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    id integer NOT NULL,
    "spaceId" integer NOT NULL,
    "userId" integer NOT NULL
);


ALTER TABLE public.space_members OWNER TO ernestomonge;

--
-- Name: space_members_id_seq; Type: SEQUENCE; Schema: public; Owner: ernestomonge
--

CREATE SEQUENCE public.space_members_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.space_members_id_seq OWNER TO ernestomonge;

--
-- Name: space_members_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ernestomonge
--

ALTER SEQUENCE public.space_members_id_seq OWNED BY public.space_members.id;


--
-- Name: spaces; Type: TABLE; Schema: public; Owner: ernestomonge
--

CREATE TABLE public.spaces (
    name text NOT NULL,
    description text,
    color text DEFAULT '#3B82F6'::text,
    icon text DEFAULT 'folder'::text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    id integer NOT NULL,
    "organizationId" integer,
    "templateId" integer,
    "isPublic" boolean DEFAULT true NOT NULL
);


ALTER TABLE public.spaces OWNER TO ernestomonge;

--
-- Name: spaces_id_seq; Type: SEQUENCE; Schema: public; Owner: ernestomonge
--

CREATE SEQUENCE public.spaces_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.spaces_id_seq OWNER TO ernestomonge;

--
-- Name: spaces_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ernestomonge
--

ALTER SEQUENCE public.spaces_id_seq OWNED BY public.spaces.id;


--
-- Name: sprint_metrics; Type: TABLE; Schema: public; Owner: ernestomonge
--

CREATE TABLE public.sprint_metrics (
    id integer NOT NULL,
    date timestamp(3) without time zone NOT NULL,
    "plannedTasks" integer DEFAULT 0 NOT NULL,
    "completedTasks" integer DEFAULT 0 NOT NULL,
    "remainingTasks" integer DEFAULT 0 NOT NULL,
    "idealRemaining" integer DEFAULT 0 NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "sprintId" integer NOT NULL
);


ALTER TABLE public.sprint_metrics OWNER TO ernestomonge;

--
-- Name: sprint_metrics_id_seq; Type: SEQUENCE; Schema: public; Owner: ernestomonge
--

CREATE SEQUENCE public.sprint_metrics_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sprint_metrics_id_seq OWNER TO ernestomonge;

--
-- Name: sprint_metrics_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ernestomonge
--

ALTER SEQUENCE public.sprint_metrics_id_seq OWNED BY public.sprint_metrics.id;


--
-- Name: sprints; Type: TABLE; Schema: public; Owner: ernestomonge
--

CREATE TABLE public.sprints (
    name text NOT NULL,
    "startDate" timestamp(3) without time zone,
    "endDate" timestamp(3) without time zone,
    status public."SprintStatus" DEFAULT 'PLANNING'::public."SprintStatus" NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    id integer NOT NULL,
    "projectId" integer NOT NULL,
    goal text
);


ALTER TABLE public.sprints OWNER TO ernestomonge;

--
-- Name: sprints_id_seq; Type: SEQUENCE; Schema: public; Owner: ernestomonge
--

CREATE SEQUENCE public.sprints_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sprints_id_seq OWNER TO ernestomonge;

--
-- Name: sprints_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ernestomonge
--

ALTER SEQUENCE public.sprints_id_seq OWNED BY public.sprints.id;


--
-- Name: tasks; Type: TABLE; Schema: public; Owner: ernestomonge
--

CREATE TABLE public.tasks (
    title text NOT NULL,
    description text,
    status text DEFAULT 'PENDING'::text NOT NULL,
    priority public."TaskPriority" DEFAULT 'MEDIUM'::public."TaskPriority" NOT NULL,
    "dueDate" timestamp(3) without time zone,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    id integer NOT NULL,
    "projectId" integer NOT NULL,
    "sprintId" integer,
    "assigneeId" integer,
    "createdById" integer NOT NULL,
    "epicId" integer,
    "parentTaskId" integer,
    "order" integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.tasks OWNER TO ernestomonge;

--
-- Name: tasks_id_seq; Type: SEQUENCE; Schema: public; Owner: ernestomonge
--

CREATE SEQUENCE public.tasks_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tasks_id_seq OWNER TO ernestomonge;

--
-- Name: tasks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ernestomonge
--

ALTER SEQUENCE public.tasks_id_seq OWNED BY public.tasks.id;


--
-- Name: template_states; Type: TABLE; Schema: public; Owner: ernestomonge
--

CREATE TABLE public.template_states (
    id integer NOT NULL,
    name text NOT NULL,
    color text DEFAULT '#9CA3AF'::text NOT NULL,
    "order" integer DEFAULT 0 NOT NULL,
    "isDefault" boolean DEFAULT false NOT NULL,
    "templateId" integer NOT NULL
);


ALTER TABLE public.template_states OWNER TO ernestomonge;

--
-- Name: template_states_id_seq; Type: SEQUENCE; Schema: public; Owner: ernestomonge
--

CREATE SEQUENCE public.template_states_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.template_states_id_seq OWNER TO ernestomonge;

--
-- Name: template_states_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ernestomonge
--

ALTER SEQUENCE public.template_states_id_seq OWNED BY public.template_states.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: ernestomonge
--

CREATE TABLE public.users (
    email text NOT NULL,
    name text,
    "passwordHash" text,
    role public."UserRole" DEFAULT 'MEMBER'::public."UserRole" NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    id integer NOT NULL,
    "organizationId" integer
);


ALTER TABLE public.users OWNER TO ernestomonge;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: ernestomonge
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.users_id_seq OWNER TO ernestomonge;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ernestomonge
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: accounts id; Type: DEFAULT; Schema: public; Owner: ernestomonge
--

ALTER TABLE ONLY public.accounts ALTER COLUMN id SET DEFAULT nextval('public.accounts_id_seq'::regclass);


--
-- Name: attachments id; Type: DEFAULT; Schema: public; Owner: ernestomonge
--

ALTER TABLE ONLY public.attachments ALTER COLUMN id SET DEFAULT nextval('public.attachments_id_seq'::regclass);


--
-- Name: audit_logs id; Type: DEFAULT; Schema: public; Owner: ernestomonge
--

ALTER TABLE ONLY public.audit_logs ALTER COLUMN id SET DEFAULT nextval('public.audit_logs_id_seq'::regclass);


--
-- Name: comments id; Type: DEFAULT; Schema: public; Owner: ernestomonge
--

ALTER TABLE ONLY public.comments ALTER COLUMN id SET DEFAULT nextval('public.comments_id_seq'::regclass);


--
-- Name: epics id; Type: DEFAULT; Schema: public; Owner: ernestomonge
--

ALTER TABLE ONLY public.epics ALTER COLUMN id SET DEFAULT nextval('public.epics_id_seq'::regclass);


--
-- Name: invitations id; Type: DEFAULT; Schema: public; Owner: ernestomonge
--

ALTER TABLE ONLY public.invitations ALTER COLUMN id SET DEFAULT nextval('public.invitations_id_seq'::regclass);


--
-- Name: member_productivity id; Type: DEFAULT; Schema: public; Owner: ernestomonge
--

ALTER TABLE ONLY public.member_productivity ALTER COLUMN id SET DEFAULT nextval('public.member_productivity_id_seq'::regclass);


--
-- Name: notifications id; Type: DEFAULT; Schema: public; Owner: ernestomonge
--

ALTER TABLE ONLY public.notifications ALTER COLUMN id SET DEFAULT nextval('public.notifications_id_seq'::regclass);


--
-- Name: organizations id; Type: DEFAULT; Schema: public; Owner: ernestomonge
--

ALTER TABLE ONLY public.organizations ALTER COLUMN id SET DEFAULT nextval('public.organizations_id_seq'::regclass);


--
-- Name: password_reset_tokens id; Type: DEFAULT; Schema: public; Owner: ernestomonge
--

ALTER TABLE ONLY public.password_reset_tokens ALTER COLUMN id SET DEFAULT nextval('public.password_reset_tokens_id_seq'::regclass);


--
-- Name: project_members id; Type: DEFAULT; Schema: public; Owner: ernestomonge
--

ALTER TABLE ONLY public.project_members ALTER COLUMN id SET DEFAULT nextval('public.project_members_id_seq'::regclass);


--
-- Name: project_templates id; Type: DEFAULT; Schema: public; Owner: ernestomonge
--

ALTER TABLE ONLY public.project_templates ALTER COLUMN id SET DEFAULT nextval('public.project_templates_id_seq'::regclass);


--
-- Name: projects id; Type: DEFAULT; Schema: public; Owner: ernestomonge
--

ALTER TABLE ONLY public.projects ALTER COLUMN id SET DEFAULT nextval('public.projects_id_seq'::regclass);


--
-- Name: sessions id; Type: DEFAULT; Schema: public; Owner: ernestomonge
--

ALTER TABLE ONLY public.sessions ALTER COLUMN id SET DEFAULT nextval('public.sessions_id_seq'::regclass);


--
-- Name: space_members id; Type: DEFAULT; Schema: public; Owner: ernestomonge
--

ALTER TABLE ONLY public.space_members ALTER COLUMN id SET DEFAULT nextval('public.space_members_id_seq'::regclass);


--
-- Name: spaces id; Type: DEFAULT; Schema: public; Owner: ernestomonge
--

ALTER TABLE ONLY public.spaces ALTER COLUMN id SET DEFAULT nextval('public.spaces_id_seq'::regclass);


--
-- Name: sprint_metrics id; Type: DEFAULT; Schema: public; Owner: ernestomonge
--

ALTER TABLE ONLY public.sprint_metrics ALTER COLUMN id SET DEFAULT nextval('public.sprint_metrics_id_seq'::regclass);


--
-- Name: sprints id; Type: DEFAULT; Schema: public; Owner: ernestomonge
--

ALTER TABLE ONLY public.sprints ALTER COLUMN id SET DEFAULT nextval('public.sprints_id_seq'::regclass);


--
-- Name: tasks id; Type: DEFAULT; Schema: public; Owner: ernestomonge
--

ALTER TABLE ONLY public.tasks ALTER COLUMN id SET DEFAULT nextval('public.tasks_id_seq'::regclass);


--
-- Name: template_states id; Type: DEFAULT; Schema: public; Owner: ernestomonge
--

ALTER TABLE ONLY public.template_states ALTER COLUMN id SET DEFAULT nextval('public.template_states_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: ernestomonge
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Data for Name: _prisma_migrations; Type: TABLE DATA; Schema: public; Owner: ernestomonge
--

COPY public._prisma_migrations (id, checksum, finished_at, migration_name, logs, rolled_back_at, started_at, applied_steps_count) FROM stdin;
5f0a80ee-3e92-4b63-9fa4-58229f27b996	48d21707ed817a9ebfb4720e6fbf873f80d1e7e330ddd22b566ec7cd4581bbf7	2025-10-17 12:39:11.283828-05	20250924034800_init	\N	\N	2025-10-17 12:39:11.008687-05	1
c7f70588-5aa1-45d7-b3ab-86ee7be33ef2	f02eb3c2b8b1f8d74f5e1060eb7b5e349b0de4a362ccf8649e062b732d7e7b8a	2025-10-17 12:39:11.353494-05	20250924041350_add_invitations	\N	\N	2025-10-17 12:39:11.285229-05	1
03e1b6a5-9f1b-48e9-afd3-0e9b785b2b85	773a87c817704214d013c4a5d51aa30d1884a2ca0534b7773622c70b7acadf98	2025-11-03 13:01:09.623373-05	20251103180109_add_performance_indexes	\N	\N	2025-11-03 13:01:09.483264-05	1
314f27c7-2eb0-4dba-80d3-6f109c70a68f	d0c0f6ba32efbcb838042c1cd91c215ee690972de91b4d8d18dacd4fd54406ec	2025-10-17 12:39:11.46148-05	20251007173934_add_epics	\N	\N	2025-10-17 12:39:11.354848-05	1
e2f192e3-1bf8-4301-b0e3-f31c386f4857	4c6446a5e7ca6bab6ca334a9529b635da9603ce0983bc8ffd882939a79d012ce	2025-10-17 12:39:40.260807-05	20251017173938_change_ids_to_int	\N	\N	2025-10-17 12:39:38.923936-05	1
8805f0bb-93e8-4b04-95a7-e99434e4965e	42514767946c6ddf0f79ed0dd27276baa987b7d5fc4c8d361149ad2bcd9357ee	2025-10-17 21:13:08.492453-05	20251018021308_add_password_reset_token	\N	\N	2025-10-17 21:13:08.41969-05	1
fd4f0945-387e-467f-85c3-af863e55b254	e3a16e4a3f777643b2c183c7b980a0ec2f384b7a215a663fcd54437839700c3c	2025-11-03 16:54:11.217127-05	20251103215411_add_goal_to_sprint	\N	\N	2025-11-03 16:54:11.16323-05	1
6931e3a0-200b-4d25-8dc1-63dd642b17f5	0f15c9626aedf6fea6ed942dba327373fdb0f064162662eca570fbeb7b7f6dda	2025-10-18 06:59:44.177421-05	20251018115944_add_subtasks_and_audit_logs	\N	\N	2025-10-18 06:59:44.060083-05	1
27e129c7-3e44-433d-992e-0ab286b74c7d	406024fa6d9e89ab58b691acf836d357b5878db496f619d602c29e9581180772	2025-10-18 07:12:24.200845-05	20251018121223_add_templates_and_metrics	\N	\N	2025-10-18 07:12:24.018682-05	1
220e5702-d99b-4d9d-bb25-bcce5a8b0ef3	d94140667b0a2944541247cc9f543bdd7de73a75357f57a2cc0330eb46d217b9	2025-10-20 17:30:43.412565-05	20251020223043_add_template_to_project	\N	\N	2025-10-20 17:30:43.301532-05	1
b22c6868-517f-45eb-a80b-0fe4dc003f6c	1e70df9ae7ecc9d2b6e08b6d7830d7fa12669e64fe184c338c1c6c5fcf410755	2025-11-03 18:03:00.929366-05	20251103230300_add_is_public_to_space	\N	\N	2025-11-03 18:03:00.881258-05	1
57308191-f815-4b2b-b4d4-c44e3acce699	aef4b7a1e20cd5a7e2d48462cd2efdcb3c4ec27f56b56a3d5a42fec8a480de6b	2025-10-21 07:56:35.888245-05	20251021125600_change_task_status_to_string	\N	\N	2025-10-21 07:56:35.738995-05	1
9783c605-ff4d-4750-a286-050a57f0df31	82b550d6f53764eaf7abaf9d9f38fe5f5d7eab1d51895b4fefcd93d4adca2ec1	2025-10-21 12:35:21.772389-05	20251021173521_add_subtask_comments_attachments_audit	\N	\N	2025-10-21 12:35:21.570906-05	1
34073c07-9772-44f7-86ca-e911fea1f2d9	122d743a0403e77ad7e0ed9447f5b8826f2fbdbc55612d936eff004dd13c2eec	2025-10-21 12:44:29.492045-05	20251021174412_add_subtask_relations	\N	\N	2025-10-21 12:44:29.485832-05	1
b9550017-4850-48b0-8e11-4e16ac297e56	4ff91988680f5b420dc5113acd5296946177e5a917a985361aa21e2a1f0ebf7c	2025-11-03 18:22:54.051722-05	20251103232253_make_organization_optional	\N	\N	2025-11-03 18:22:54.043651-05	1
47713804-9b41-4cfb-b84d-051464c81a9d	090710cc120e399722f091bd21e986f4da62f760af59eca659be05df3f454886	2025-11-02 14:21:17.242445-05	20251102192117_add_template_to_space	\N	\N	2025-11-02 14:21:17.211219-05	1
666ae027-ef96-4f85-a7ee-5e0eae3c48d6	d9e6b9c03f2c99d7958f90f337622dd2e6ce781e4c2afcd818b9f001602227d9	2025-11-03 08:31:23.185929-05	20251103083056_merge_subtasks_into_tasks	\N	\N	2025-11-03 08:31:23.074169-05	1
15866d63-e263-4919-a1ba-5434cbd36c35	aa4befd50291a508dd20f545c3cea5b602da9d6440fbe79f2bd712920d97de4d	2025-11-04 09:31:32.807201-05	20251104143132_add_owner_role	\N	\N	2025-11-04 09:31:32.762473-05	1
9e957889-f9d1-43cc-8355-5c7f231f67f2	8c99a8c8164944e2f28fa906fae8cf44658a2b5e9843ccabb8317e87d31c0996	\N	20251009211558_revert_to_simple_email_fields	A migration failed to apply. New migrations cannot be applied before the error is recovered from. Read more about how to resolve migration issues in a production database: https://pris.ly/d/migrate-resolve\n\nMigration name: 20251009211558_revert_to_simple_email_fields\n\nDatabase error code: 42P01\n\nDatabase error:\nERROR: relation "clients" does not exist\n\nDbError { severity: "ERROR", parsed_severity: Some(Error), code: SqlState(E42P01), message: "relation \\"clients\\" does not exist", detail: None, hint: None, position: None, where_: None, schema: None, table: None, column: None, datatype: None, constraint: None, file: Some("namespace.c"), line: Some(436), routine: Some("RangeVarGetRelidExtended") }\n\n   0: sql_schema_connector::apply_migration::apply_script\n           with migration_name="20251009211558_revert_to_simple_email_fields"\n             at schema-engine/connectors/sql-schema-connector/src/apply_migration.rs:113\n   1: schema_commands::commands::apply_migrations::Applying migration\n           with migration_name="20251009211558_revert_to_simple_email_fields"\n             at schema-engine/commands/src/commands/apply_migrations.rs:95\n   2: schema_core::state::ApplyMigrations\n             at schema-engine/core/src/state.rs:244	\N	2025-11-07 19:14:00.409792-05	0
\.


--
-- Data for Name: accounts; Type: TABLE DATA; Schema: public; Owner: ernestomonge
--

COPY public.accounts (type, provider, "providerAccountId", refresh_token, access_token, expires_at, token_type, scope, id_token, session_state, id, "userId") FROM stdin;
\.


--
-- Data for Name: attachments; Type: TABLE DATA; Schema: public; Owner: ernestomonge
--

COPY public.attachments (filename, url, size, "mimeType", "createdAt", id, "taskId", "uploadedById") FROM stdin;
303339898_2025115172835546.pdf	https://testflow-archivos.s3.us-east-2.amazonaws.com/attachments/10/78/1762453316581-303339898_2025115172835546.pdf	218261	application/pdf	2025-11-06 18:21:58.898	1	78	34
Captura de pantalla 2025-11-06 a la(s) 13.13.28.png	https://atalaya-archivos.s3.us-east-1.amazonaws.com/attachments/10/79/1762453693726-Captura_de_pantalla_2025-11-06_a_la_s__13.13.28.png	146088	image/png	2025-11-06 18:28:14.591	2	79	34
sire.sql	https://atalaya-archivos.s3.us-east-1.amazonaws.com/attachments/10/76/1762534884733-sire.sql	2926	application/octet-stream	2025-11-07 17:01:25.236	3	76	34
Captura de pantalla 2025-11-11 a la(s) 09.47.06.png	https://atalaya-archivos.s3.us-east-1.amazonaws.com/attachments/tasks/78/1762873229141-Captura_de_pantalla_2025-11-11_a_la_s__09.47.06.png	50146	image/png	2025-11-11 15:00:30.279	4	78	38
\.


--
-- Data for Name: audit_logs; Type: TABLE DATA; Schema: public; Owner: ernestomonge
--

COPY public.audit_logs (id, action, field, "oldValue", "newValue", details, "createdAt", "taskId", "userId") FROM stdin;
1	Cambió el estado	Estado	EN_PROGRESO	EN_REVISIÓN	\N	2025-11-06 16:13:18.099	78	34
2	Cambió la fecha de vencimiento	Fecha de vencimiento	1/11/2025	2/11/2025	\N	2025-11-06 16:13:18.115	78	34
3	Cambió el título	Título	Volead	Volea a Tope	\N	2025-11-06 16:13:49.968	78	34
4	Cambió la asignación	Asignado	Usuario 34	Usuario 38	\N	2025-11-06 16:13:49.972	78	34
5	Cambió la fecha de vencimiento	Fecha de vencimiento	2/11/2025	7/11/2025	\N	2025-11-06 16:13:49.973	78	34
6	Cambió la asignación	Asignado	Ernesto Monge	Admin User	\N	2025-11-06 16:17:39.159	78	34
7	Cambió el estado	Estado	EN_REVISIÓN	TESTING	\N	2025-11-06 17:46:17.498	78	34
8	Cambió la fecha de vencimiento	Fecha de vencimiento	7/11/2025	13/11/2025	\N	2025-11-06 18:31:16.749	78	34
9	Cambió el estado	Estado	TESTING	COMPLETADO	\N	2025-11-06 18:31:54.689	78	34
10	Cambió el estado	Estado	TESTING	EN_REVISIÓN	\N	2025-11-06 18:34:29.013	77	34
11	Cambió el estado	Estado	EN_REVISIÓN	TESTING	\N	2025-11-06 18:34:40.869	77	34
12	Cambió el estado	Estado	COMPLETADO	EN_REVISIÓN	\N	2025-11-06 18:34:44.302	75	34
13	Cambió el estado	Estado	COMPLETADO	EN_REVISIÓN	\N	2025-11-06 18:34:47.615	78	34
14	Cambió el estado	Estado	EN_REVISIÓN	EN_PROGRESO	\N	2025-11-06 18:39:11.423	78	34
15	Cambió la asignación	Asignado	Admin User	Ernesto Monge	\N	2025-11-06 20:59:43.853	78	34
16	Cambió la asignación	Asignado	Sin asignar	Ignacio Mesa	\N	2025-11-07 16:58:22.611	76	34
17	Cambió la asignación	Asignado	Sin asignar	Ignacio Mesa	\N	2025-11-07 17:17:38.027	94	34
\.


--
-- Data for Name: comments; Type: TABLE DATA; Schema: public; Owner: ernestomonge
--

COPY public.comments (content, "createdAt", "updatedAt", id, "taskId", "userId") FROM stdin;
Ya terminé el formulario de registro, ¿podrías revisarlo?	2025-10-31 16:20:26.816	2025-10-31 16:20:26.816	19	63	35
Perfecto! Lo reviso en un momento y te doy feedback.	2025-10-31 16:20:26.826	2025-10-31 16:20:26.826	20	63	34
Necesito ayuda con la validación del token. ¿Alguien tiene experiencia con JWT?	2025-10-31 16:20:26.827	2025-10-31 16:20:26.827	21	64	36
Claro! Te puedo ayudar. Revisa la documentación de jsonwebtoken.	2025-10-31 16:20:26.828	2025-10-31 16:20:26.828	22	64	35
hols	2025-11-02 20:44:51.069	2025-11-02 20:44:51.069	23	75	34
carambas	2025-11-03 14:19:07.89	2025-11-03 14:19:07.89	24	77	34
no me parece	2025-11-03 14:19:11.31	2025-11-03 14:19:11.31	25	77	34
estas cosas que dices	2025-11-03 14:19:15.314	2025-11-03 14:19:15.314	26	77	34
cp,p vas?	2025-11-03 14:29:44.131	2025-11-03 14:29:44.131	27	80	34
si bien posicionado	2025-11-03 15:23:25.778	2025-11-03 15:23:25.778	28	79	34
bien y tu?	2025-11-03 15:23:34.745	2025-11-03 15:23:34.745	29	80	34
holas	2025-11-06 16:14:17.003	2025-11-06 16:14:17.003	30	78	34
hola @Ignacio Mesa como estas?	2025-11-07 16:53:01.376	2025-11-07 16:53:01.376	31	76	34
@Ignacio Mesa que andas?	2025-11-07 16:58:55.128	2025-11-07 16:58:55.128	32	76	34
\.


--
-- Data for Name: epics; Type: TABLE DATA; Schema: public; Owner: ernestomonge
--

COPY public.epics (name, description, color, status, "startDate", "targetDate", "createdAt", "updatedAt", id, "projectId") FROM stdin;
User Authentication	Implementar sistema completo de autenticación y autorización	#3B82F6	IN_PROGRESS	2024-01-01 00:00:00	2024-02-15 00:00:00	2025-10-31 16:20:26.675	2025-10-31 16:20:26.675	33	37
Payment Integration	Integración con pasarelas de pago	#10B981	IN_PROGRESS	2024-02-01 00:00:00	2024-03-15 00:00:00	2025-10-31 16:20:26.681	2025-10-31 16:20:26.681	34	37
Mobile UI	Diseño e implementación de la interfaz móvil	#8B5CF6	TODO	\N	\N	2025-10-31 16:20:26.682	2025-10-31 16:20:26.682	35	38
Social Media Campaign	Campaña en redes sociales para Q2	#EC4899	IN_PROGRESS	2024-04-01 00:00:00	2024-06-30 00:00:00	2025-10-31 16:20:26.683	2025-10-31 16:20:26.683	36	39
Epica Big 4	esta es una jugadores TOP TOP	#8B5CF6	IN_PROGRESS	\N	\N	2025-11-03 16:08:37.475	2025-11-03 16:08:37.475	37	41
Epica Next Gen	\N	#F59E0B	IN_PROGRESS	\N	\N	2025-11-03 16:08:48.006	2025-11-03 16:08:48.006	38	41
Epiccc	\N	#8B5CF6	IN_PROGRESS	\N	\N	2025-11-03 17:51:32.467	2025-11-03 17:51:32.467	39	42
Epic Win	\N	#8B5CF6	IN_PROGRESS	\N	\N	2025-11-04 02:49:33.563	2025-11-04 02:49:33.563	40	43
\.


--
-- Data for Name: invitations; Type: TABLE DATA; Schema: public; Owner: ernestomonge
--

COPY public.invitations (email, role, status, token, "expiresAt", "createdAt", "updatedAt", id, "organizationId", "invitedById") FROM stdin;
\.


--
-- Data for Name: member_productivity; Type: TABLE DATA; Schema: public; Owner: ernestomonge
--

COPY public.member_productivity (id, date, "tasksCompleted", "tasksInProgress", "tasksPending", "productivityScore", "createdAt", "userId", "projectId") FROM stdin;
\.


--
-- Data for Name: notifications; Type: TABLE DATA; Schema: public; Owner: ernestomonge
--

COPY public.notifications (title, message, type, "isRead", "createdAt", id, "userId", "taskId", "projectId", link) FROM stdin;
Nueva tarea asignada	Se te asignó la tarea "Agregar recuperación de contraseña"	TASK_ASSIGNED	f	2025-10-31 16:20:26.829	10	35	\N	\N	\N
Comentario en tu tarea	Admin User comentó en "Implementar login con JWT"	INFO	f	2025-10-31 16:20:26.83	11	36	\N	\N	\N
Tarea completada	María García completó la tarea "Implementar registro de usuarios"	SUCCESS	t	2025-10-31 16:20:26.831	12	34	\N	\N	\N
Nueva tarea asignada	Se te asignó la tarea "Crear contenido para Instagram"	TASK_ASSIGNED	f	2025-10-31 16:20:26.832	13	35	\N	\N	\N
Nueva tarea asignada	Se te ha asignado la tarea: REsistencia	TASK_ASSIGNED	t	2025-11-07 16:58:22.614	14	40	76	42	/projects/42?taskId=76
Nuevo comentario	Admin User comentó en la tarea: REsistencia	COMMENT_ADDED	t	2025-11-07 16:58:55.137	15	40	76	42	/projects/42?taskId=76
Nueva tarea asignada	Se te ha asignado la tarea: Hello	TASK_ASSIGNED	f	2025-11-07 17:17:38.03	16	40	94	42	/projects/42?taskId=94
\.


--
-- Data for Name: organizations; Type: TABLE DATA; Schema: public; Owner: ernestomonge
--

COPY public.organizations (name, "createdAt", "updatedAt", id) FROM stdin;
Lilab Tech	2025-10-31 16:20:26.225	2025-10-31 16:20:26.225	10
Lilab	2025-11-03 22:40:20.854	2025-11-03 22:40:20.854	11
Lilab	2025-11-03 22:40:53.688	2025-11-03 22:40:53.688	12
Lilab	2025-11-03 22:41:22.315	2025-11-03 22:41:22.315	13
\.


--
-- Data for Name: password_reset_tokens; Type: TABLE DATA; Schema: public; Owner: ernestomonge
--

COPY public.password_reset_tokens (id, token, email, "expiresAt", used, "createdAt") FROM stdin;
\.


--
-- Data for Name: project_members; Type: TABLE DATA; Schema: public; Owner: ernestomonge
--

COPY public.project_members (role, "joinedAt", "updatedAt", id, "projectId", "userId") FROM stdin;
OWNER	2025-10-31 16:20:26.483	2025-10-31 16:20:26.483	79	37	34
MEMBER	2025-10-31 16:20:26.483	2025-10-31 16:20:26.483	80	37	35
MEMBER	2025-10-31 16:20:26.483	2025-10-31 16:20:26.483	81	37	36
OWNER	2025-10-31 16:20:26.665	2025-10-31 16:20:26.665	82	38	34
MEMBER	2025-10-31 16:20:26.665	2025-10-31 16:20:26.665	83	38	36
OWNER	2025-10-31 16:20:26.667	2025-10-31 16:20:26.667	84	39	34
MEMBER	2025-10-31 16:20:26.667	2025-10-31 16:20:26.667	85	39	35
OWNER	2025-10-31 16:20:26.67	2025-10-31 16:20:26.67	86	40	34
ADMIN	2025-10-31 16:20:26.67	2025-10-31 16:20:26.67	87	40	36
OWNER	2025-11-02 19:52:38.526	2025-11-02 19:52:38.526	88	41	34
OWNER	2025-11-02 19:56:10.822	2025-11-02 19:56:10.822	89	42	34
OWNER	2025-11-04 02:11:37.648	2025-11-04 02:11:37.648	90	43	38
VIEWER	2025-11-04 02:28:16.489	2025-11-04 02:28:16.489	91	43	34
OWNER	2025-11-04 16:34:52.767	2025-11-04 16:34:52.767	97	44	41
MEMBER	2025-11-04 16:35:14.002	2025-11-04 16:35:14.002	98	44	34
MEMBER	2025-11-04 17:16:13.885	2025-11-04 17:16:13.885	100	41	38
OWNER	2025-11-06 20:05:16.399	2025-11-06 20:05:16.399	101	45	38
MEMBER	2025-11-06 20:05:35.34	2025-11-06 20:05:35.34	102	45	34
MEMBER	2025-11-07 13:46:38.689	2025-11-07 13:46:38.689	103	42	38
MEMBER	2025-11-07 13:46:43.186	2025-11-07 13:46:43.186	104	42	40
\.


--
-- Data for Name: project_templates; Type: TABLE DATA; Schema: public; Owner: ernestomonge
--

COPY public.project_templates (id, name, description, category, icon, color, "isDefault", "usageCount", "createdAt", "updatedAt", "organizationId", "createdById") FROM stdin;
1	Desarrollo de Software	Plantilla para proyectos de desarrollo con metodología ágil	DESARROLLO_SOFTWARE	Code	#3B82F6	t	0	2025-10-18 12:15:39.7	2025-10-18 12:15:39.7	\N	\N
2	Marketing	Gestión de campañas y contenido de marketing	MARKETING	Megaphone	#EC4899	t	0	2025-10-18 12:15:39.727	2025-10-18 12:15:39.727	\N	\N
3	Diseño	Flujo de trabajo para proyectos de diseño y creatividad	DISENO	Palette	#8B5CF6	t	0	2025-10-18 12:15:39.729	2025-10-18 12:15:39.729	\N	\N
4	Ventas	Pipeline de ventas y gestión de oportunidades	VENTAS	TrendingUp	#10B981	t	0	2025-10-18 12:15:39.731	2025-10-18 12:15:39.731	\N	\N
5	General	Plantilla simple para cualquier tipo de proyecto	GENERAL	Folder	#6B7280	t	0	2025-10-18 12:15:39.734	2025-10-18 12:15:39.734	\N	\N
9	Templaet Admin	asi es!	GENERAL	TrendingUp	#3B82F6	f	0	2025-11-04 14:22:38.379	2025-11-04 14:22:38.379	10	34
10	EMP	\N	GENERAL	Zap	#3B82F6	f	0	2025-11-04 14:23:22.494	2025-11-04 14:23:22.494	11	38
\.


--
-- Data for Name: projects; Type: TABLE DATA; Schema: public; Owner: ernestomonge
--

COPY public.projects (name, description, "createdAt", "updatedAt", id, "organizationId", "spaceId", "templateId") FROM stdin;
E-commerce Platform	Plataforma de comercio electrónico con integración de pagos	2025-10-31 16:20:26.483	2025-10-31 16:20:26.483	37	10	27	\N
Mobile App CRM	Aplicación móvil para gestión de clientes	2025-10-31 16:20:26.665	2025-10-31 16:20:26.665	38	10	27	\N
Campaña Q2 2024	Estrategia de marketing para el segundo trimestre	2025-10-31 16:20:26.667	2025-10-31 16:20:26.667	39	10	28	\N
CI/CD Pipeline	Automatización de deployments y testing	2025-10-31 16:20:26.67	2025-11-02 18:36:06.312	40	10	29	\N
Carlitos Alcaraz	\N	2025-11-02 19:56:10.817	2025-11-02 19:56:10.817	42	10	38	2
Fonseca	La torre de Rio	2025-11-04 02:11:37.623	2025-11-04 02:11:37.623	43	11	38	3
El mas grande	\N	2025-11-04 16:34:52.726	2025-11-04 16:34:52.726	44	10	37	2
Roger	\N	2025-11-06 20:05:16.374	2025-11-06 20:05:16.374	45	11	38	4
Janik Sinner ITALIAN	El Italiano frio	2025-11-02 19:52:38.506	2025-11-03 16:45:17.736	41	11	38	1
\.


--
-- Data for Name: sessions; Type: TABLE DATA; Schema: public; Owner: ernestomonge
--

COPY public.sessions ("sessionToken", expires, id, "userId") FROM stdin;
\.


--
-- Data for Name: space_members; Type: TABLE DATA; Schema: public; Owner: ernestomonge
--

COPY public.space_members (role, "joinedAt", "updatedAt", id, "spaceId", "userId") FROM stdin;
MEMBER	2025-11-04 01:57:30.051	2025-11-04 01:57:30.051	80	38	38
MEMBER	2025-11-04 14:15:46.417	2025-11-04 14:15:46.417	82	40	34
VIEWER	2025-11-04 15:41:23.07	2025-11-04 15:41:23.07	83	38	40
OWNER	2025-11-04 16:42:41.971	2025-11-04 16:42:41.971	84	27	34
OWNER	2025-11-04 16:42:41.987	2025-11-04 16:42:41.987	85	28	34
OWNER	2025-11-04 16:42:41.988	2025-11-04 16:42:41.988	86	29	34
OWNER	2025-11-04 16:42:41.988	2025-11-04 16:42:41.988	87	30	34
OWNER	2025-11-04 16:42:41.989	2025-11-04 16:42:41.989	88	34	34
OWNER	2025-11-04 16:42:41.99	2025-11-04 16:42:41.99	89	35	34
OWNER	2025-11-04 16:42:41.991	2025-11-04 16:42:41.991	90	36	34
OWNER	2025-11-04 16:42:41.992	2025-11-04 16:42:41.992	91	37	34
OWNER	2025-11-02 19:49:38.196	2025-11-02 19:49:38.196	78	38	34
OWNER	2025-11-03 23:09:31.459	2025-11-03 23:09:31.459	79	39	34
OWNER	2025-11-04 14:10:14.383	2025-11-04 14:10:14.383	81	40	38
ADMIN	2025-11-06 20:04:47.114	2025-11-06 20:04:47.114	93	41	38
\.


--
-- Data for Name: spaces; Type: TABLE DATA; Schema: public; Owner: ernestomonge
--

COPY public.spaces (name, description, color, icon, "createdAt", "updatedAt", id, "organizationId", "templateId", "isPublic") FROM stdin;
Desarrollo de Producto	Espacio dedicado al desarrollo de software	#3B82F6	Code	2025-10-31 16:20:26.462	2025-10-31 16:20:26.462	27	10	\N	t
Marketing Digital	Campañas y estrategias de marketing	#EC4899	Megaphone	2025-10-31 16:20:26.477	2025-10-31 16:20:26.477	28	10	\N	t
Operaciones	Gestión de procesos internos y DevOps	#10B981	Settings	2025-10-31 16:20:26.48	2025-10-31 16:20:26.48	29	10	\N	t
dmemem	Gestión de procesos internos y DevOps	#8B5CF6	Folder	2025-11-02 03:57:32.412	2025-11-02 04:04:26.969	30	10	\N	t
jjjjjj	hkjhkhkjhk	#3B82F6	Folder	2025-11-02 19:05:05.452	2025-11-02 19:05:29.005	34	10	\N	t
cdvsdvsdf	\N	#3B82F6	Folder	2025-11-02 19:05:43.287	2025-11-02 19:05:43.287	35	10	\N	t
yyyyy	\N	#3B82F6	Folder	2025-11-02 19:36:22.267	2025-11-02 19:36:22.267	36	10	3	t
Liga 1	Canal oficial de la liga 1 max	#3B82F6	Folder	2025-11-02 19:37:10.671	2025-11-02 19:37:10.671	37	10	2	t
ATP	Tenis Pro	#3B82F6	Folder	2025-11-02 19:49:38.196	2025-11-03 23:09:21.585	38	10	4	f
Espacio EMP	\N	#3B82F6	Folder	2025-11-04 14:10:14.383	2025-11-04 14:10:14.383	40	11	3	f
Calcio	cccccc	#8B5CF6	Folder	2025-11-03 23:09:31.459	2025-11-04 17:14:24.96	39	10	2	f
Hols rspacio	\N	#3B82F6	Folder	2025-11-06 20:04:47.114	2025-11-06 20:04:47.114	41	11	3	t
\.


--
-- Data for Name: sprint_metrics; Type: TABLE DATA; Schema: public; Owner: ernestomonge
--

COPY public.sprint_metrics (id, date, "plannedTasks", "completedTasks", "remainingTasks", "idealRemaining", "createdAt", "sprintId") FROM stdin;
\.


--
-- Data for Name: sprints; Type: TABLE DATA; Schema: public; Owner: ernestomonge
--

COPY public.sprints (name, "startDate", "endDate", status, "createdAt", "updatedAt", id, "projectId", goal) FROM stdin;
Sprint 1	2025-11-03 00:00:00	2025-11-17 00:00:00	PLANNING	2025-11-04 02:11:38.231	2025-11-04 02:11:38.231	51	43	\N
Sprint 2	2025-11-18 00:00:00	2025-12-02 00:00:00	PLANNING	2025-11-04 02:11:38.715	2025-11-04 02:11:38.715	52	43	\N
Sprint 3	2025-12-03 00:00:00	2025-12-17 00:00:00	PLANNING	2025-11-04 02:11:39.182	2025-11-04 02:11:39.182	53	43	\N
Sprint 4	2025-12-18 00:00:00	2025-12-20 00:00:00	PLANNING	2025-11-04 02:11:39.617	2025-11-04 02:11:39.617	54	43	\N
afsdfsdf	2025-01-01 00:00:00	2025-03-01 00:00:00	PLANNING	2025-11-07 17:13:40.418	2025-11-07 17:13:40.418	55	42	\N
Sprint 1 - Auth Foundation	2024-01-15 00:00:00	2024-01-29 00:00:00	ACTIVE	2025-10-31 16:20:26.685	2025-10-31 16:20:26.685	45	37	\N
Sprint 2 - Payment Setup	2024-02-01 00:00:00	2024-02-15 00:00:00	PLANNING	2025-10-31 16:20:26.708	2025-10-31 16:20:26.708	46	37	\N
Sprint 1 - Mobile Foundations	2024-01-08 00:00:00	2024-01-22 00:00:00	ACTIVE	2025-10-31 16:20:26.711	2025-10-31 16:20:26.711	47	38	\N
Sprint 1 - Campaign Launch	2024-04-01 00:00:00	2024-04-15 00:00:00	ACTIVE	2025-10-31 16:20:26.711	2025-10-31 16:20:26.711	48	39	\N
Sprint 2	2025-11-17 00:00:00	2025-11-30 00:00:00	PLANNING	2025-11-03 16:52:40.155	2025-11-03 16:52:40.155	50	41	\N
Sprint 1	2025-11-03 00:00:00	2025-11-28 00:00:00	COMPLETED	2025-11-03 16:52:02.848	2025-11-03 21:59:58.394	49	41	 asdf af sdfghsd fh dfhd sf
\.


--
-- Data for Name: tasks; Type: TABLE DATA; Schema: public; Owner: ernestomonge
--

COPY public.tasks (title, description, status, priority, "dueDate", "createdAt", "updatedAt", id, "projectId", "sprintId", "assigneeId", "createdById", "epicId", "parentTaskId", "order") FROM stdin;
doble falta	\N	TESTING	MEDIUM	\N	2025-11-03 15:17:35.24	2025-11-06 18:32:16.72	83	41	\N	34	34	\N	77	2
Tamal	\N	BRIEFING	MEDIUM	\N	2025-11-04 02:25:16.764	2025-11-04 02:25:16.764	87	43	\N	\N	38	\N	\N	0
Alto	\N	BRIEFING	MEDIUM	\N	2025-11-04 02:25:21.321	2025-11-04 02:25:21.321	88	43	\N	\N	38	\N	\N	0
Gorra	\N	BRIEFING	MEDIUM	\N	2025-11-04 02:25:29.85	2025-11-04 02:25:29.85	89	43	\N	\N	38	\N	\N	0
Blanco	\N	BRIEFING	MEDIUM	\N	2025-11-04 02:25:33.846	2025-11-04 02:25:33.846	90	43	\N	\N	38	\N	\N	0
white	\N	Briefing	MEDIUM	\N	2025-11-04 02:54:26.996	2025-11-04 02:54:26.996	91	43	\N	\N	38	\N	90	0
Saque	\N	TESTING	HIGH	2025-10-27 00:00:00	2025-11-03 14:13:34.272	2025-11-06 18:34:40.838	77	41	50	\N	34	38	\N	0
Revesito	que gran golpe	EN_REVISIÓN	MEDIUM	2025-11-13 17:00:00	2025-11-02 19:55:47.283	2025-11-06 18:34:44.298	75	41	50	34	34	37	\N	0
Net	\N	COMPLETADO	MEDIUM	2025-11-26 00:00:00	2025-11-03 15:17:28.101	2025-11-04 17:27:57.616	81	41	\N	\N	34	\N	77	0
3333111	\N	COMPLETADO	MEDIUM	2025-10-27 00:00:00	2025-11-03 19:11:01.858	2025-11-06 19:20:36.229	86	41	\N	\N	34	\N	78	2
hoils	\N	POR_HACER	MEDIUM	2025-11-20 17:00:00	2025-11-03 14:28:34.703	2025-11-04 17:30:23.322	80	41	\N	34	34	\N	78	1
Ace	\N	COMPLETADO	MEDIUM	\N	2025-11-03 15:17:31.823	2025-11-06 19:28:23.251	82	41	\N	34	34	\N	77	1
aja	\N	Idea	MEDIUM	\N	2025-11-03 15:21:07.051	2025-11-03 15:21:07.051	84	42	\N	\N	34	\N	76	0
eje	\N	ARCHIVADO	MEDIUM	\N	2025-11-03 15:21:10.161	2025-11-03 15:21:14.857	85	42	\N	\N	34	\N	76	1
Saque directo	\N	PENDING	MEDIUM	\N	2025-11-06 20:05:51.239	2025-11-06 20:05:51.239	93	45	\N	\N	38	\N	\N	0
Implementar registro de usuarios	Crear formulario y endpoint para registro de nuevos usuarios	COMPLETED	HIGH	2024-01-20 00:00:00	2025-10-31 16:20:26.712	2025-10-31 16:20:26.712	63	37	45	35	34	33	\N	0
grey	\N	APROBADO	MEDIUM	\N	2025-11-04 02:54:32.896	2025-11-06 20:48:29.467	92	43	\N	\N	38	\N	90	1
Implementar login con JWT	Sistema de autenticación usando tokens JWT	IN_PROGRESS	HIGH	2024-01-25 00:00:00	2025-10-31 16:20:26.773	2025-10-31 16:20:26.773	64	37	45	36	34	33	\N	0
Agregar recuperación de contraseña	Flujo completo de reset de password	PENDING	MEDIUM	2024-01-28 00:00:00	2025-10-31 16:20:26.774	2025-10-31 16:20:26.774	65	37	45	35	34	33	\N	0
Integrar Stripe API	Configurar SDK de Stripe y endpoints básicos	PENDING	HIGH	\N	2025-10-31 16:20:26.776	2025-10-31 16:20:26.776	66	37	46	36	34	34	\N	0
Crear flujo de checkout	Interfaz de usuario para proceso de pago	PENDING	HIGH	\N	2025-10-31 16:20:26.778	2025-10-31 16:20:26.778	67	37	\N	35	34	34	\N	0
Diseñar pantallas principales	Mockups de las 5 pantallas principales de la app	COMPLETED	HIGH	2024-01-15 00:00:00	2025-10-31 16:20:26.779	2025-10-31 16:20:26.779	68	38	47	36	34	35	\N	0
Configurar React Native	Setup inicial del proyecto móvil	IN_PROGRESS	HIGH	2024-01-20 00:00:00	2025-10-31 16:20:26.779	2025-10-31 16:20:26.779	69	38	47	36	34	35	\N	0
Implementar navegación	Sistema de navegación entre pantallas	PENDING	MEDIUM	\N	2025-10-31 16:20:26.78	2025-10-31 16:20:26.78	70	38	47	36	34	35	\N	0
Crear contenido para Instagram	10 posts programados para el mes	IN_PROGRESS	HIGH	2024-04-10 00:00:00	2025-10-31 16:20:26.78	2025-10-31 16:20:26.78	71	39	48	35	34	36	\N	0
Diseñar campaña de email	Template y copy para campaña de email marketing	PENDING	MEDIUM	2024-04-12 00:00:00	2025-10-31 16:20:26.781	2025-10-31 16:20:26.781	72	39	48	35	34	36	\N	0
Configurar GitHub Actions	Pipeline de CI/CD para testing y deployment	COMPLETED	HIGH	\N	2025-10-31 16:20:26.803	2025-10-31 16:20:26.803	73	40	\N	36	34	\N	\N	0
Dockerizar aplicación	Crear Dockerfiles y docker-compose	IN_PROGRESS	MEDIUM	\N	2025-10-31 16:20:26.805	2025-10-31 16:20:26.805	74	40	\N	36	34	\N	\N	0
buen posicionamientofffff3	\N	POR_HACER	HIGH	2025-11-28 17:00:00	2025-11-03 14:21:46.55	2025-11-06 20:55:41.543	79	41	\N	38	34	\N	78	0
Volea a Tope	\N	EN_PROGRESO	LOW	2025-11-13 17:00:00	2025-11-03 14:13:42.783	2025-11-06 20:59:43.779	78	41	49	38	34	37	\N	0
REsistencia	que tal stmina	PLANIFICACIÓN	MEDIUM	\N	2025-11-02 19:56:21.439	2025-11-07 16:58:22.597	76	42	\N	40	34	\N	\N	0
Hello	\N	IDEA	MEDIUM	\N	2025-11-07 17:17:31.033	2025-11-07 17:17:38.018	94	42	\N	40	34	\N	\N	0
\.


--
-- Data for Name: template_states; Type: TABLE DATA; Schema: public; Owner: ernestomonge
--

COPY public.template_states (id, name, color, "order", "isDefault", "templateId") FROM stdin;
1	Por Hacer	#9CA3AF	0	t	1
2	En Progreso	#3B82F6	1	f	1
3	En Revisión	#F59E0B	2	f	1
4	Testing	#8B5CF6	3	f	1
5	Completado	#10B981	4	f	1
6	Idea	#9CA3AF	0	t	2
7	Planificación	#3B82F6	1	f	2
8	En Producción	#F59E0B	2	f	2
9	Publicado	#10B981	3	f	2
10	Archivado	#6B7280	4	f	2
11	Briefing	#9CA3AF	0	t	3
12	Boceto	#3B82F6	1	f	3
13	Diseño	#8B5CF6	2	f	3
14	Revisión	#F59E0B	3	f	3
15	Aprobado	#10B981	4	f	3
16	Lead	#9CA3AF	0	t	4
17	Contactado	#3B82F6	1	f	4
18	Calificado	#8B5CF6	2	f	4
19	Propuesta	#F59E0B	3	f	4
20	Negociación	#EF4444	4	f	4
21	Ganado	#10B981	5	f	4
22	Perdido	#6B7280	6	f	4
23	Por Hacer	#9CA3AF	0	t	5
24	En Progreso	#3B82F6	1	f	5
25	Completado	#10B981	2	f	5
48	Por Hacer	#9CA3AF	1	t	9
49	En Progreso	#3B82F6	2	f	9
50	Completado	#10B981	3	f	9
51	Vamos	#9CA3AF	4	f	9
52	5to set	#9CA3AF	5	f	9
53	Super tiebreak	#6B7280	6	f	9
54	Seva	#9CA3AF	1	f	10
55	Jerarquita	#9CA3AF	2	f	10
56	Mati	#9CA3AF	3	f	10
57	Rodri	#9CA3AF	4	f	10
58	Jairoco	#9CA3AF	5	f	10
59	Valegol	#14B8A6	6	f	10
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: ernestomonge
--

COPY public.users (email, name, "passwordHash", role, "createdAt", "updatedAt", id, "organizationId") FROM stdin;
maria@lilab.com	María García	$2b$10$KicSI1pDHn.XRc4JGeZTSuvrrfrEbZSjcWmxOI.g7ecorJhaTBhli	MEMBER	2025-10-31 16:20:26.459	2025-10-31 16:20:26.459	35	10
carlos@lilab.com	Carlos Rodríguez	$2b$10$KicSI1pDHn.XRc4JGeZTSuvrrfrEbZSjcWmxOI.g7ecorJhaTBhli	MEMBER	2025-10-31 16:20:26.46	2025-10-31 16:20:26.46	36	10
ana@lilab.com	Ana López	$2b$10$KicSI1pDHn.XRc4JGeZTSuvrrfrEbZSjcWmxOI.g7ecorJhaTBhli	READ_ONLY	2025-10-31 16:20:26.461	2025-10-31 16:20:26.461	37	10
ernesto.monge@lilab.pe	Ernesto Monge	$2b$10$Do0E5XeYrHnBP8YRjgnZF.mpAKenIfh2OEEdp2xDoRt8l0Fnxj4sK	ADMIN	2025-11-03 22:40:20.887	2025-11-03 22:40:20.887	38	11
luis.otoya@lilab.pe	Luis Otoya	$2b$10$6T1g1xNCQ6p2cohlHMsaduww7V/qCngHE6UbIwV4ncxuD.RRmFsAa	ADMIN	2025-11-03 22:40:53.69	2025-11-03 22:40:53.69	39	12
admin@lilab.com	Admin User	$2b$10$KicSI1pDHn.XRc4JGeZTSuvrrfrEbZSjcWmxOI.g7ecorJhaTBhli	ADMIN	2025-10-31 16:20:26.425	2025-10-31 16:20:26.425	34	10
juancito@lilab.pe	Juan Perez	$2b$10$gWVmEPhDB8pM14wVRfjbzON3r7rZKmEstcAsWWAglIkre4C2Rtjey	MEMBER	2025-11-04 16:33:28.001	2025-11-04 16:33:28.001	41	10
ignacio.mesa@lilab.pe	Ignacio Mesa	$2b$10$kCu/zs9/2T4yfMs9xKLwwuEHbHER.o9ftYtzmIcSAzzRZlS/4oJcS	MEMBER	2025-11-03 22:41:22.32	2025-11-07 16:53:49.762	40	13
\.


--
-- Name: accounts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ernestomonge
--

SELECT pg_catalog.setval('public.accounts_id_seq', 1, false);


--
-- Name: attachments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ernestomonge
--

SELECT pg_catalog.setval('public.attachments_id_seq', 4, true);


--
-- Name: audit_logs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ernestomonge
--

SELECT pg_catalog.setval('public.audit_logs_id_seq', 17, true);


--
-- Name: comments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ernestomonge
--

SELECT pg_catalog.setval('public.comments_id_seq', 32, true);


--
-- Name: epics_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ernestomonge
--

SELECT pg_catalog.setval('public.epics_id_seq', 40, true);


--
-- Name: invitations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ernestomonge
--

SELECT pg_catalog.setval('public.invitations_id_seq', 1, false);


--
-- Name: member_productivity_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ernestomonge
--

SELECT pg_catalog.setval('public.member_productivity_id_seq', 1, false);


--
-- Name: notifications_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ernestomonge
--

SELECT pg_catalog.setval('public.notifications_id_seq', 16, true);


--
-- Name: organizations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ernestomonge
--

SELECT pg_catalog.setval('public.organizations_id_seq', 13, true);


--
-- Name: password_reset_tokens_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ernestomonge
--

SELECT pg_catalog.setval('public.password_reset_tokens_id_seq', 1, false);


--
-- Name: project_members_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ernestomonge
--

SELECT pg_catalog.setval('public.project_members_id_seq', 104, true);


--
-- Name: project_templates_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ernestomonge
--

SELECT pg_catalog.setval('public.project_templates_id_seq', 10, true);


--
-- Name: projects_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ernestomonge
--

SELECT pg_catalog.setval('public.projects_id_seq', 45, true);


--
-- Name: sessions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ernestomonge
--

SELECT pg_catalog.setval('public.sessions_id_seq', 1, false);


--
-- Name: space_members_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ernestomonge
--

SELECT pg_catalog.setval('public.space_members_id_seq', 93, true);


--
-- Name: spaces_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ernestomonge
--

SELECT pg_catalog.setval('public.spaces_id_seq', 41, true);


--
-- Name: sprint_metrics_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ernestomonge
--

SELECT pg_catalog.setval('public.sprint_metrics_id_seq', 1, false);


--
-- Name: sprints_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ernestomonge
--

SELECT pg_catalog.setval('public.sprints_id_seq', 55, true);


--
-- Name: tasks_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ernestomonge
--

SELECT pg_catalog.setval('public.tasks_id_seq', 94, true);


--
-- Name: template_states_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ernestomonge
--

SELECT pg_catalog.setval('public.template_states_id_seq', 59, true);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ernestomonge
--

SELECT pg_catalog.setval('public.users_id_seq', 41, true);


--
-- Name: _prisma_migrations _prisma_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: ernestomonge
--

ALTER TABLE ONLY public._prisma_migrations
    ADD CONSTRAINT _prisma_migrations_pkey PRIMARY KEY (id);


--
-- Name: accounts accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: ernestomonge
--

ALTER TABLE ONLY public.accounts
    ADD CONSTRAINT accounts_pkey PRIMARY KEY (id);


--
-- Name: attachments attachments_pkey; Type: CONSTRAINT; Schema: public; Owner: ernestomonge
--

ALTER TABLE ONLY public.attachments
    ADD CONSTRAINT attachments_pkey PRIMARY KEY (id);


--
-- Name: audit_logs audit_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: ernestomonge
--

ALTER TABLE ONLY public.audit_logs
    ADD CONSTRAINT audit_logs_pkey PRIMARY KEY (id);


--
-- Name: comments comments_pkey; Type: CONSTRAINT; Schema: public; Owner: ernestomonge
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_pkey PRIMARY KEY (id);


--
-- Name: epics epics_pkey; Type: CONSTRAINT; Schema: public; Owner: ernestomonge
--

ALTER TABLE ONLY public.epics
    ADD CONSTRAINT epics_pkey PRIMARY KEY (id);


--
-- Name: invitations invitations_pkey; Type: CONSTRAINT; Schema: public; Owner: ernestomonge
--

ALTER TABLE ONLY public.invitations
    ADD CONSTRAINT invitations_pkey PRIMARY KEY (id);


--
-- Name: member_productivity member_productivity_pkey; Type: CONSTRAINT; Schema: public; Owner: ernestomonge
--

ALTER TABLE ONLY public.member_productivity
    ADD CONSTRAINT member_productivity_pkey PRIMARY KEY (id);


--
-- Name: notifications notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: ernestomonge
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);


--
-- Name: organizations organizations_pkey; Type: CONSTRAINT; Schema: public; Owner: ernestomonge
--

ALTER TABLE ONLY public.organizations
    ADD CONSTRAINT organizations_pkey PRIMARY KEY (id);


--
-- Name: password_reset_tokens password_reset_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: ernestomonge
--

ALTER TABLE ONLY public.password_reset_tokens
    ADD CONSTRAINT password_reset_tokens_pkey PRIMARY KEY (id);


--
-- Name: project_members project_members_pkey; Type: CONSTRAINT; Schema: public; Owner: ernestomonge
--

ALTER TABLE ONLY public.project_members
    ADD CONSTRAINT project_members_pkey PRIMARY KEY (id);


--
-- Name: project_templates project_templates_pkey; Type: CONSTRAINT; Schema: public; Owner: ernestomonge
--

ALTER TABLE ONLY public.project_templates
    ADD CONSTRAINT project_templates_pkey PRIMARY KEY (id);


--
-- Name: projects projects_pkey; Type: CONSTRAINT; Schema: public; Owner: ernestomonge
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT projects_pkey PRIMARY KEY (id);


--
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: ernestomonge
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- Name: space_members space_members_pkey; Type: CONSTRAINT; Schema: public; Owner: ernestomonge
--

ALTER TABLE ONLY public.space_members
    ADD CONSTRAINT space_members_pkey PRIMARY KEY (id);


--
-- Name: spaces spaces_pkey; Type: CONSTRAINT; Schema: public; Owner: ernestomonge
--

ALTER TABLE ONLY public.spaces
    ADD CONSTRAINT spaces_pkey PRIMARY KEY (id);


--
-- Name: sprint_metrics sprint_metrics_pkey; Type: CONSTRAINT; Schema: public; Owner: ernestomonge
--

ALTER TABLE ONLY public.sprint_metrics
    ADD CONSTRAINT sprint_metrics_pkey PRIMARY KEY (id);


--
-- Name: sprints sprints_pkey; Type: CONSTRAINT; Schema: public; Owner: ernestomonge
--

ALTER TABLE ONLY public.sprints
    ADD CONSTRAINT sprints_pkey PRIMARY KEY (id);


--
-- Name: tasks tasks_pkey; Type: CONSTRAINT; Schema: public; Owner: ernestomonge
--

ALTER TABLE ONLY public.tasks
    ADD CONSTRAINT tasks_pkey PRIMARY KEY (id);


--
-- Name: template_states template_states_pkey; Type: CONSTRAINT; Schema: public; Owner: ernestomonge
--

ALTER TABLE ONLY public.template_states
    ADD CONSTRAINT template_states_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: ernestomonge
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: accounts_provider_providerAccountId_key; Type: INDEX; Schema: public; Owner: ernestomonge
--

CREATE UNIQUE INDEX "accounts_provider_providerAccountId_key" ON public.accounts USING btree (provider, "providerAccountId");


--
-- Name: epics_projectId_idx; Type: INDEX; Schema: public; Owner: ernestomonge
--

CREATE INDEX "epics_projectId_idx" ON public.epics USING btree ("projectId");


--
-- Name: epics_status_idx; Type: INDEX; Schema: public; Owner: ernestomonge
--

CREATE INDEX epics_status_idx ON public.epics USING btree (status);


--
-- Name: invitations_email_organizationId_key; Type: INDEX; Schema: public; Owner: ernestomonge
--

CREATE UNIQUE INDEX "invitations_email_organizationId_key" ON public.invitations USING btree (email, "organizationId");


--
-- Name: invitations_token_key; Type: INDEX; Schema: public; Owner: ernestomonge
--

CREATE UNIQUE INDEX invitations_token_key ON public.invitations USING btree (token);


--
-- Name: member_productivity_userId_projectId_date_key; Type: INDEX; Schema: public; Owner: ernestomonge
--

CREATE UNIQUE INDEX "member_productivity_userId_projectId_date_key" ON public.member_productivity USING btree ("userId", "projectId", date);


--
-- Name: password_reset_tokens_email_idx; Type: INDEX; Schema: public; Owner: ernestomonge
--

CREATE INDEX password_reset_tokens_email_idx ON public.password_reset_tokens USING btree (email);


--
-- Name: password_reset_tokens_token_key; Type: INDEX; Schema: public; Owner: ernestomonge
--

CREATE UNIQUE INDEX password_reset_tokens_token_key ON public.password_reset_tokens USING btree (token);


--
-- Name: project_members_projectId_idx; Type: INDEX; Schema: public; Owner: ernestomonge
--

CREATE INDEX "project_members_projectId_idx" ON public.project_members USING btree ("projectId");


--
-- Name: project_members_projectId_userId_key; Type: INDEX; Schema: public; Owner: ernestomonge
--

CREATE UNIQUE INDEX "project_members_projectId_userId_key" ON public.project_members USING btree ("projectId", "userId");


--
-- Name: project_members_userId_idx; Type: INDEX; Schema: public; Owner: ernestomonge
--

CREATE INDEX "project_members_userId_idx" ON public.project_members USING btree ("userId");


--
-- Name: projects_organizationId_idx; Type: INDEX; Schema: public; Owner: ernestomonge
--

CREATE INDEX "projects_organizationId_idx" ON public.projects USING btree ("organizationId");


--
-- Name: projects_spaceId_idx; Type: INDEX; Schema: public; Owner: ernestomonge
--

CREATE INDEX "projects_spaceId_idx" ON public.projects USING btree ("spaceId");


--
-- Name: sessions_sessionToken_key; Type: INDEX; Schema: public; Owner: ernestomonge
--

CREATE UNIQUE INDEX "sessions_sessionToken_key" ON public.sessions USING btree ("sessionToken");


--
-- Name: space_members_spaceId_userId_key; Type: INDEX; Schema: public; Owner: ernestomonge
--

CREATE UNIQUE INDEX "space_members_spaceId_userId_key" ON public.space_members USING btree ("spaceId", "userId");


--
-- Name: sprint_metrics_sprintId_date_key; Type: INDEX; Schema: public; Owner: ernestomonge
--

CREATE UNIQUE INDEX "sprint_metrics_sprintId_date_key" ON public.sprint_metrics USING btree ("sprintId", date);


--
-- Name: sprints_projectId_idx; Type: INDEX; Schema: public; Owner: ernestomonge
--

CREATE INDEX "sprints_projectId_idx" ON public.sprints USING btree ("projectId");


--
-- Name: sprints_status_idx; Type: INDEX; Schema: public; Owner: ernestomonge
--

CREATE INDEX sprints_status_idx ON public.sprints USING btree (status);


--
-- Name: tasks_assigneeId_idx; Type: INDEX; Schema: public; Owner: ernestomonge
--

CREATE INDEX "tasks_assigneeId_idx" ON public.tasks USING btree ("assigneeId");


--
-- Name: tasks_epicId_idx; Type: INDEX; Schema: public; Owner: ernestomonge
--

CREATE INDEX "tasks_epicId_idx" ON public.tasks USING btree ("epicId");


--
-- Name: tasks_priority_idx; Type: INDEX; Schema: public; Owner: ernestomonge
--

CREATE INDEX tasks_priority_idx ON public.tasks USING btree (priority);


--
-- Name: tasks_projectId_idx; Type: INDEX; Schema: public; Owner: ernestomonge
--

CREATE INDEX "tasks_projectId_idx" ON public.tasks USING btree ("projectId");


--
-- Name: tasks_projectId_parentTaskId_idx; Type: INDEX; Schema: public; Owner: ernestomonge
--

CREATE INDEX "tasks_projectId_parentTaskId_idx" ON public.tasks USING btree ("projectId", "parentTaskId");


--
-- Name: tasks_sprintId_idx; Type: INDEX; Schema: public; Owner: ernestomonge
--

CREATE INDEX "tasks_sprintId_idx" ON public.tasks USING btree ("sprintId");


--
-- Name: tasks_status_idx; Type: INDEX; Schema: public; Owner: ernestomonge
--

CREATE INDEX tasks_status_idx ON public.tasks USING btree (status);


--
-- Name: users_email_key; Type: INDEX; Schema: public; Owner: ernestomonge
--

CREATE UNIQUE INDEX users_email_key ON public.users USING btree (email);


--
-- Name: accounts accounts_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ernestomonge
--

ALTER TABLE ONLY public.accounts
    ADD CONSTRAINT "accounts_userId_fkey" FOREIGN KEY ("userId") REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: attachments attachments_taskId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ernestomonge
--

ALTER TABLE ONLY public.attachments
    ADD CONSTRAINT "attachments_taskId_fkey" FOREIGN KEY ("taskId") REFERENCES public.tasks(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: attachments attachments_uploadedById_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ernestomonge
--

ALTER TABLE ONLY public.attachments
    ADD CONSTRAINT "attachments_uploadedById_fkey" FOREIGN KEY ("uploadedById") REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: audit_logs audit_logs_taskId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ernestomonge
--

ALTER TABLE ONLY public.audit_logs
    ADD CONSTRAINT "audit_logs_taskId_fkey" FOREIGN KEY ("taskId") REFERENCES public.tasks(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: audit_logs audit_logs_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ernestomonge
--

ALTER TABLE ONLY public.audit_logs
    ADD CONSTRAINT "audit_logs_userId_fkey" FOREIGN KEY ("userId") REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: comments comments_taskId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ernestomonge
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT "comments_taskId_fkey" FOREIGN KEY ("taskId") REFERENCES public.tasks(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: comments comments_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ernestomonge
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT "comments_userId_fkey" FOREIGN KEY ("userId") REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: epics epics_projectId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ernestomonge
--

ALTER TABLE ONLY public.epics
    ADD CONSTRAINT "epics_projectId_fkey" FOREIGN KEY ("projectId") REFERENCES public.projects(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: invitations invitations_invitedById_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ernestomonge
--

ALTER TABLE ONLY public.invitations
    ADD CONSTRAINT "invitations_invitedById_fkey" FOREIGN KEY ("invitedById") REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: invitations invitations_organizationId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ernestomonge
--

ALTER TABLE ONLY public.invitations
    ADD CONSTRAINT "invitations_organizationId_fkey" FOREIGN KEY ("organizationId") REFERENCES public.organizations(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: member_productivity member_productivity_projectId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ernestomonge
--

ALTER TABLE ONLY public.member_productivity
    ADD CONSTRAINT "member_productivity_projectId_fkey" FOREIGN KEY ("projectId") REFERENCES public.projects(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: member_productivity member_productivity_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ernestomonge
--

ALTER TABLE ONLY public.member_productivity
    ADD CONSTRAINT "member_productivity_userId_fkey" FOREIGN KEY ("userId") REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: notifications notifications_projectId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ernestomonge
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT "notifications_projectId_fkey" FOREIGN KEY ("projectId") REFERENCES public.projects(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: notifications notifications_taskId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ernestomonge
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT "notifications_taskId_fkey" FOREIGN KEY ("taskId") REFERENCES public.tasks(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: notifications notifications_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ernestomonge
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT "notifications_userId_fkey" FOREIGN KEY ("userId") REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: project_members project_members_projectId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ernestomonge
--

ALTER TABLE ONLY public.project_members
    ADD CONSTRAINT "project_members_projectId_fkey" FOREIGN KEY ("projectId") REFERENCES public.projects(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: project_members project_members_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ernestomonge
--

ALTER TABLE ONLY public.project_members
    ADD CONSTRAINT "project_members_userId_fkey" FOREIGN KEY ("userId") REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: project_templates project_templates_createdById_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ernestomonge
--

ALTER TABLE ONLY public.project_templates
    ADD CONSTRAINT "project_templates_createdById_fkey" FOREIGN KEY ("createdById") REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: project_templates project_templates_organizationId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ernestomonge
--

ALTER TABLE ONLY public.project_templates
    ADD CONSTRAINT "project_templates_organizationId_fkey" FOREIGN KEY ("organizationId") REFERENCES public.organizations(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: projects projects_organizationId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ernestomonge
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT "projects_organizationId_fkey" FOREIGN KEY ("organizationId") REFERENCES public.organizations(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: projects projects_spaceId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ernestomonge
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT "projects_spaceId_fkey" FOREIGN KEY ("spaceId") REFERENCES public.spaces(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: projects projects_templateId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ernestomonge
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT "projects_templateId_fkey" FOREIGN KEY ("templateId") REFERENCES public.project_templates(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: sessions sessions_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ernestomonge
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT "sessions_userId_fkey" FOREIGN KEY ("userId") REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: space_members space_members_spaceId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ernestomonge
--

ALTER TABLE ONLY public.space_members
    ADD CONSTRAINT "space_members_spaceId_fkey" FOREIGN KEY ("spaceId") REFERENCES public.spaces(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: space_members space_members_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ernestomonge
--

ALTER TABLE ONLY public.space_members
    ADD CONSTRAINT "space_members_userId_fkey" FOREIGN KEY ("userId") REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: spaces spaces_organizationId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ernestomonge
--

ALTER TABLE ONLY public.spaces
    ADD CONSTRAINT "spaces_organizationId_fkey" FOREIGN KEY ("organizationId") REFERENCES public.organizations(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: spaces spaces_templateId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ernestomonge
--

ALTER TABLE ONLY public.spaces
    ADD CONSTRAINT "spaces_templateId_fkey" FOREIGN KEY ("templateId") REFERENCES public.project_templates(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: sprint_metrics sprint_metrics_sprintId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ernestomonge
--

ALTER TABLE ONLY public.sprint_metrics
    ADD CONSTRAINT "sprint_metrics_sprintId_fkey" FOREIGN KEY ("sprintId") REFERENCES public.sprints(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: sprints sprints_projectId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ernestomonge
--

ALTER TABLE ONLY public.sprints
    ADD CONSTRAINT "sprints_projectId_fkey" FOREIGN KEY ("projectId") REFERENCES public.projects(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: tasks tasks_assigneeId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ernestomonge
--

ALTER TABLE ONLY public.tasks
    ADD CONSTRAINT "tasks_assigneeId_fkey" FOREIGN KEY ("assigneeId") REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: tasks tasks_createdById_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ernestomonge
--

ALTER TABLE ONLY public.tasks
    ADD CONSTRAINT "tasks_createdById_fkey" FOREIGN KEY ("createdById") REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: tasks tasks_epicId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ernestomonge
--

ALTER TABLE ONLY public.tasks
    ADD CONSTRAINT "tasks_epicId_fkey" FOREIGN KEY ("epicId") REFERENCES public.epics(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: tasks tasks_parentTaskId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ernestomonge
--

ALTER TABLE ONLY public.tasks
    ADD CONSTRAINT "tasks_parentTaskId_fkey" FOREIGN KEY ("parentTaskId") REFERENCES public.tasks(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: tasks tasks_projectId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ernestomonge
--

ALTER TABLE ONLY public.tasks
    ADD CONSTRAINT "tasks_projectId_fkey" FOREIGN KEY ("projectId") REFERENCES public.projects(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: tasks tasks_sprintId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ernestomonge
--

ALTER TABLE ONLY public.tasks
    ADD CONSTRAINT "tasks_sprintId_fkey" FOREIGN KEY ("sprintId") REFERENCES public.sprints(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: template_states template_states_templateId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ernestomonge
--

ALTER TABLE ONLY public.template_states
    ADD CONSTRAINT "template_states_templateId_fkey" FOREIGN KEY ("templateId") REFERENCES public.project_templates(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: users users_organizationId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ernestomonge
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT "users_organizationId_fkey" FOREIGN KEY ("organizationId") REFERENCES public.organizations(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: ernestomonge
--

REVOKE USAGE ON SCHEMA public FROM PUBLIC;


--
-- PostgreSQL database dump complete
--

\unrestrict OmsIXOucjxB0glJSh0Rc8lIo74oosq2TnxVpWY7LXHzKRehhr2Mzyxe0BohY7f8

