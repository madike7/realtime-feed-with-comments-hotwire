ActiveSupport.on_load :action_text_rich_text do #re-open ActionText::RichText class mesw tou ActiveSupport.on_load
  before_save { self.plain_text_body = body.to_plain_text } #metefera apo to model post edw, wste na einai general gia kathe model me rich text

  # ena ILIKE query den ypologizei ta stop words (px. the, a, in, at ...)
  # px. an psaksw "tree is tall" tha kanei match to "this tree is tall", 
  # enw an psaksw "tree tall" den tha kanei match
  # Gia na agnow ta stop words, prepei na metatrepsw kai to query kai to column sto opoio kanw query se text search vectors (to_tsvector)
  # To string query to metatrepw pernwntas to sto websearch_to_tsquery
  # kai to plain_text_body column pernwntas to sto to_tsvector
  # Gia kalytero performance, orizw ena GIN index sto action_text_rich_texts.plain_text_body gia na apothikeuw to value pou epistrefei to_tsvector
  scope :with_body_containing, ->(query) { where <<~SQL, query }  
    to_tsvector('english', plain_text_body) @@ websearch_to_tsquery(?)
  SQL
end