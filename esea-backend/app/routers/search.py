from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session
from sqlalchemy import text
from app.database import get_db

router = APIRouter(prefix="/search", tags=["Search"])

@router.get("/")
def global_search(
    q: str = Query(..., min_length=1),
    limit: int = Query(20, ge=1, le=50),
    offset: int = Query(0, ge=0),
    type: str | None = None,
    db: Session = Depends(get_db),
):
    queries = []
    
    if type is None or type == "discussion":
        queries.append("""
            SELECT 
                id::text, 
                'discussion' as entity_type, 
                title, 
                ts_headline('english', coalesce(content, ''), plainto_tsquery('english', :q), 'StartSel=<b>, StopSel=</b>, MaxWords=20, MinWords=5') as preview,
                created_at,
                ts_rank(search_vector, plainto_tsquery('english', :q)) as relevance_score
            FROM discussions
            WHERE search_vector @@ plainto_tsquery('english', :q)
        """)
        
    if type is None or type != "discussion":
        type_filter = "AND type = :type" if type else ""
        
        queries.append(f"""
            SELECT 
                id::text, 
                type as entity_type, 
                title, 
                ts_headline('english', coalesce(short_description, full_description, ''), plainto_tsquery('english', :q), 'StartSel=<b>, StopSel=</b>, MaxWords=20, MinWords=5') as preview,
                published_at as created_at,
                ts_rank(search_vector, plainto_tsquery('english', :q)) as relevance_score
            FROM contents
            WHERE search_vector @@ plainto_tsquery('english', :q)
            {type_filter}
        """)
        
    if not queries:
        return {"results": [], "total_count": 0}
        
    union_query = " UNION ALL ".join(queries)
    
    final_query = text(f"""
        SELECT * FROM (
            {union_query}
        ) as combined_search
        ORDER BY relevance_score DESC, created_at DESC
        LIMIT :limit OFFSET :offset
    """)
    
    params = {"q": q, "limit": limit, "offset": offset}
    if type and type != "discussion":
        params["type"] = type
        
    results = db.execute(final_query, params).fetchall()
    
    output = []
    for row in results:
        output.append({
            "id": row.id,
            "entity_type": row.entity_type,
            "title": row.title,
            "preview": row.preview,
            "created_at": row.created_at,
            "relevance_score": float(row.relevance_score)
        })
        
    return {
        "results": output,
        "query": q,
        "limit": limit,
        "offset": offset
    }
