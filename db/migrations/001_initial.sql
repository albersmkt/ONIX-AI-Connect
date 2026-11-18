-- ONIX AI Connect — initial schema for Neon PostgreSQL
-- Execute in the Neon SQL Editor using the ONIX project's dedicated database.
-- No demonstration data. All rows are isolated by organization_id.
CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE IF NOT EXISTS organizations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL CHECK (length(trim(name)) BETWEEN 2 AND 120),
  segment text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS users (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  email text NOT NULL UNIQUE,
  display_name text,
  -- Login provider subject; never store plaintext passwords here.
  auth_provider text NOT NULL,
  auth_subject text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (auth_provider,auth_subject)
);

CREATE TABLE IF NOT EXISTS organization_members (
  organization_id uuid NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  role text NOT NULL CHECK (role IN ('owner','admin','agent')),
  created_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY(organization_id,user_id)
);

CREATE TABLE IF NOT EXISTS assistants (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id uuid NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  name text NOT NULL CHECK (length(trim(name)) BETWEEN 2 AND 80),
  tone text NOT NULL DEFAULT 'consultivo',
  instructions text NOT NULL DEFAULT '',
  enabled boolean NOT NULL DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (id,organization_id)
);

CREATE TABLE IF NOT EXISTS contacts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id uuid NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  whatsapp_id text NOT NULL,
  name text,
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE(organization_id,whatsapp_id),
  UNIQUE(id,organization_id)
);

CREATE TABLE IF NOT EXISTS conversations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id uuid NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  contact_id uuid NOT NULL,
  status text NOT NULL DEFAULT 'open' CHECK(status IN ('open','assigned','closed')),
  assigned_user_id uuid REFERENCES users(id),
  ai_paused boolean NOT NULL DEFAULT true,
  updated_at timestamptz NOT NULL DEFAULT now(),
  FOREIGN KEY(contact_id, organization_id) REFERENCES contacts(id,organization_id),
  UNIQUE(id,organization_id)
);

CREATE TABLE IF NOT EXISTS messages (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id uuid NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  conversation_id uuid NOT NULL,
  direction text NOT NULL CHECK(direction IN ('in','out')),
  body text,
  provider_message_id text,
  created_at timestamptz NOT NULL DEFAULT now(),
  FOREIGN KEY(conversation_id, organization_id) REFERENCES conversations(id,organization_id)
);
CREATE UNIQUE INDEX IF NOT EXISTS messages_provider_dedupe
  ON messages(organization_id,provider_message_id) WHERE provider_message_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_assistants_org ON assistants(organization_id);
CREATE INDEX IF NOT EXISTS idx_conversations_org ON conversations(organization_id,updated_at DESC);
CREATE INDEX IF NOT EXISTS idx_messages_conversation ON messages(conversation_id,created_at DESC);

-- Important: a server-side DB connection alone does NOT provide tenant security.
-- Before exposing CRUD endpoints, enforce authenticated membership checks on EVERY query,
-- use least-privilege roles, and implement database-enforced row-level security.
-- Do NOT grant public write access or connect browser code directly to this database.
