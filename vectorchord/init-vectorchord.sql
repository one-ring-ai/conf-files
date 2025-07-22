CREATE EXTENSION IF NOT EXISTS vchord CASCADE;
CREATE EXTENSION IF NOT EXISTS pg_tokenizer CASCADE;
CREATE EXTENSION IF NOT EXISTS vchord_bm25 CASCADE;

-- Create tables for document vector storage
CREATE TABLE IF NOT EXISTS document_vectors (
    id BIGSERIAL PRIMARY KEY,
    vector_id VARCHAR(255) UNIQUE NOT NULL,
    document_id VARCHAR(255) NOT NULL,
    file_id VARCHAR(255) NOT NULL,
    category_id VARCHAR(255) NOT NULL,
    user_id VARCHAR(255) NOT NULL,
    chunk_id VARCHAR(255) NOT NULL,
    chunk_index INTEGER NOT NULL,
    chunk_text TEXT NOT NULL,
    start_index INTEGER DEFAULT 0,
    end_index INTEGER DEFAULT 0,
    embedding vector(1024), -- OpenAI text-embedding-3-small dimension
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for efficient querying
CREATE INDEX IF NOT EXISTS idx_document_vectors_document_id ON document_vectors(document_id);
CREATE INDEX IF NOT EXISTS idx_document_vectors_file_id ON document_vectors(file_id);
CREATE INDEX IF NOT EXISTS idx_document_vectors_category_id ON document_vectors(category_id);
CREATE INDEX IF NOT EXISTS idx_document_vectors_user_id ON document_vectors(user_id);
CREATE INDEX IF NOT EXISTS idx_document_vectors_vector_id ON document_vectors(vector_id);

-- Create VectorChord index for similarity search
CREATE INDEX IF NOT EXISTS idx_document_vectors_embedding_vchordrq
ON document_vectors USING vchordrq (embedding vector_l2_ops)
WITH (options = $$
residual_quantization = true
[build.internal]
lists = [1024]
spherical_centroids = false
$$);

-- Create table for document metadata
CREATE TABLE IF NOT EXISTS document_metadata (
    id BIGSERIAL PRIMARY KEY,
    document_id VARCHAR(255) UNIQUE NOT NULL,
    file_id VARCHAR(255) NOT NULL,
    filename VARCHAR(500) NOT NULL,
    original_name VARCHAR(500) NOT NULL,
    mime_type VARCHAR(100) NOT NULL,
    size BIGINT NOT NULL,
    category_id VARCHAR(255) NOT NULL,
    user_id VARCHAR(255) NOT NULL,
    total_chunks INTEGER DEFAULT 0,
    total_vectors INTEGER DEFAULT 0,
    extraction_metadata JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for document metadata
CREATE INDEX IF NOT EXISTS idx_document_metadata_document_id ON document_metadata(document_id);
CREATE INDEX IF NOT EXISTS idx_document_metadata_file_id ON document_metadata(file_id);
CREATE INDEX IF NOT EXISTS idx_document_metadata_category_id ON document_metadata(category_id);
CREATE INDEX IF NOT EXISTS idx_document_metadata_user_id ON document_metadata(user_id);