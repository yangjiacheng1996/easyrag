# easyrag
build my own rag system based on best open-source projects

# structure
## parser
1. stirling-pdf docker container： Anything convert to PDF。
2. minerU2.0 web api： Convert PDF to Markdwon.
3. muchunker: Markdown post-condition , then split text into chunks.using LLM setting abstract and 3 possible questions for each chunk.
4. vector: using embedding model to transform chunks, abstracts, questions into vectors.

## searcher
1. spliter: split user query to tokens.
2. melisearch: use same embedding model as vector transforming tokens into vectors,use Melisearch match chunks' vectors.
3. rerank: Use the RSE method and rerank model to reorder the matched chunks.
4. rag: put 3 top relative chunks in LLM , return the final answer, all system is going to be a openai api key.
5. mcp: expose all rag system as a tool within mcp protocol.

## manager
1. global settings： your LLM ，embedding model，rerank model，workspace.
2. health check: we follow the SOA structure ,each component should be exposed as a port, and health checking is necessary.
3. knowledge base lifecycle： create ， set ， execute parser , remove .

## doc
For more detail about each component，read docs！
