-- ============================================================================
-- 00001_extensions.sql — PostgreSQL extensions Ganacsi depends on.
-- Docs: docs/MIGRATIONS.md §00001
-- ============================================================================

-- Real-earth geography types + distance functions (branch geofencing).
create extension if not exists postgis;

-- Trigram indexes for fast fuzzy text search ("search everywhere" requirement).
create extension if not exists pg_trgm;
