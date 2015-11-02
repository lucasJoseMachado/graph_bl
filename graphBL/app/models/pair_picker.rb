class PairPicker
  def self.execute
    pairs = GraphDatabase.execute_query("#{self.pair_select_query} LIMIT 1000").flatten
  end

  private
    def self.pair_select_query
      "MATCH (a:Point)
        WHERE a.score IS NOT NULL
          AND a.score > 0
      WITH DISTINCT a as a
        MATCH (a)-[r]-(c:Point)
        WHERE c.cluster_id <> a.cluster_id OR c.cluster IS NULL
      WITH DISTINCT a as a
        MATCH (b:Point)
          WHERE id(a) < id(b)
            AND b.score IS NOT NULL
            and b.score > 0
            AND a.cluster_id < b.cluster_id
      WITH DISTINCT a as a, b as b
        MATCH (b)-[r]-(c:Point)
        WHERE c.cluster_id <> b.cluster_id OR c.cluster IS NULL
      WITH DISTINCT a as a, b as b
        RETURN {origin: {id: a.id, score: a.score}, destination: {id: b.id, score: b.score}}
        ORDER BY (a.score + b.score) DESC"
    end
end
