CREATE TABLE IF NOT EXISTS dbo.objects
(
    id                  VARCHAR(21) NOT NULL DEFAULT nanoid() UNIQUE,
    entity_id           VARCHAR(21),
    chinese_name        VARCHAR(512),
    chinese_description VARCHAR(4000),
    english_name        VARCHAR(512),
    english_description VARCHAR(4000),
    created_at          timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at          timestamptz,
    owner_id            VARCHAR(21),
    click_count         INT                  DEFAULT 0 NOT NULL,
    outlink_count       INT,
    inlink_count        INT,
    is_hidden           BOOLEAN              DEFAULT FALSE NOT NULL,
    CONSTRAINT pk_dbo_objects PRIMARY KEY (id),
    CONSTRAINT fk_dbo_objects_owner_id FOREIGN KEY (owner_id) REFERENCES auth.users
);

ALTER TABLE auth.users
    ADD CONSTRAINT
        fk_auth_users_id FOREIGN KEY (id) REFERENCES dbo.objects;

CREATE INDEX IF NOT EXISTS idx_object_chinese_name ON dbo.objects (chinese_name);

CREATE TABLE IF NOT EXISTS dbo.object_relations
(
    oid1        VARCHAR(21)                           NOT NULL,
    oid2        VARCHAR(21)                           NOT NULL,
    rank        INT,
    description VARCHAR(1000),
    created_at  timestamptz DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT pk_dbo_object_relation PRIMARY KEY (oid1, oid2),
    CONSTRAINT fk_dbo_object_relation_oid1 FOREIGN KEY (oid1) REFERENCES dbo.objects ON DELETE CASCADE,
    CONSTRAINT fk_dbo_object_relation_oid2 FOREIGN KEY (oid2) REFERENCES dbo.objects ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS dbo.entities
(
    id            VARCHAR(21)                           NOT NULL DEFAULT nanoid() UNIQUE,
    rank          INT GENERATED ALWAYS AS IDENTITY (START WITH 100),
    chinese_name  VARCHAR(50),
    english_name  VARCHAR(50),
    is_relational BOOLEAN     DEFAULT FALSE             NOT NULL,
    is_hideable   BOOLEAN     DEFAULT FALSE             NOT NULL,
    is_deletable  BOOLEAN     DEFAULT FALSE             NOT NULL,
    created_at    timestamptz DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at    timestamptz DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT pk_dbo_entity PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS dbo.classes
(
    id                  VARCHAR(21)               NOT NULL DEFAULT nanoid() UNIQUE,
    entity_id           VARCHAR(21),
    chinese_name        VARCHAR(256),
    chinese_description VARCHAR(4000),
    english_name        VARCHAR(256),
    english_description VARCHAR(4000),
    id_path             VARCHAR(2300)             NOT NULL,
    name_path           VARCHAR(2300)             NOT NULL,
    created_at          timestamptz               NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          timestamptz               NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at          timestamptz,
    object_count        INT         DEFAULT 0     NOT NULL,
    class_rank          SMALLINT    DEFAULT 0     NOT NULL,
    object_rank         SMALLINT    DEFAULT 0     NOT NULL,
    hierarchy_level     SMALLINT                  NOT NULL,
    click_count         INT         DEFAULT 0     NOT NULL,
    keywords            TEXT[]      DEFAULT '{}'  NOT NULL,
    owner_id            VARCHAR(21) DEFAULT NULL,
    is_hidden           BOOLEAN     DEFAULT FALSE NOT NULL,
    is_child            BOOLEAN     DEFAULT FALSE NOT NULL,
    CONSTRAINT pk_dbo_class PRIMARY KEY (id),
    CONSTRAINT fk_dbo_class_entities FOREIGN KEY (entity_id) REFERENCES dbo.entities,
    CONSTRAINT fk_dbo_class_owner_id FOREIGN KEY (owner_id) REFERENCES auth.users,
    CONSTRAINT qu_dbo_class_id_path UNIQUE (id_path),
    CONSTRAINT qu_dbo_class_name_path UNIQUE (name_path)
);

CREATE TABLE IF NOT EXISTS dbo.co
(
    cid              VARCHAR(21) NOT NULL,
    oid              VARCHAR(21) NOT NULL,
    rank             SMALLINT GENERATED ALWAYS AS IDENTITY (START WITH 100),
    membership_grade INT,
    description      VARCHAR(1000),
    created_at       timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_dbo_co PRIMARY KEY (cid, oid),
    CONSTRAINT fk_dbo_co_cid FOREIGN KEY (cid) REFERENCES dbo.classes ON DELETE CASCADE,
    CONSTRAINT fk_dbo_co_oid FOREIGN KEY (oid) REFERENCES dbo.objects ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS dbo.inheritances
(
    pcid             VARCHAR(21) NOT NULL,
    ccid             VARCHAR(21) NOT NULL,
    rank             SMALLINT,
    membership_grade INT,
    CONSTRAINT pk_dbo_inheritance PRIMARY KEY (pcid, ccid),
    CONSTRAINT fk_dbo_inheritance_pcid FOREIGN KEY (pcid) REFERENCES dbo.classes ON DELETE CASCADE,
    CONSTRAINT fk_dbo_inheritance_ccid FOREIGN KEY (ccid) REFERENCES dbo.classes ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS dbo.permissions
(
    class_id        VARCHAR(21)        NOT NULL,
    role_type       BOOLEAN            NOT NULL,
    role_id         VARCHAR(21)        NOT NULL,
    permission_bits SMALLINT DEFAULT 1 NOT NULL,
    CONSTRAINT uq_dbo_permissions UNIQUE (class_id, role_type, role_id),
    CONSTRAINT fk_dbo_permissions_class_id FOREIGN KEY (class_id) REFERENCES dbo.classes ON DELETE CASCADE
);

COMMENT ON COLUMN dbo.permissions.role_type IS 'True表示是使用者,False表示是群組';
COMMENT ON COLUMN dbo.permissions.role_id IS '由RoleType決定值為Auth.Roles.ID或Auth.User.ID';


CREATE TABLE IF NOT EXISTS dbo.permission_enum
(
    id  TEXT,
    bit SMALLINT NOT NULL,
    CONSTRAINT pk_permission_enum PRIMARY KEY (id),
    CONSTRAINT uq_permission_enum UNIQUE (bit)
);

INSERT INTO dbo.permission_enum(id, bit)
VALUES ('read-class', 1),
       ('read-object', 2),
       ('insert', 4),
       ('delete', 8),
       ('update', 16),
       ('modify', 32),
       ('subscribe', 64);
