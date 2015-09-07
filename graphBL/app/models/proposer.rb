class Proposer
  def self.execute clusters: 2, scorer: true, pairs_to_pick: 50
    Cluster.execute(clusters) unless clusters == false
    Scorer.execute unless scorer == false
    pairs = PairPicker.execute(pairs_to_pick)
    pairs.each do |pair|
      pair["path"] = PathPlanner.execute(pair["point_a"], pair["point_b"])
    end
    return pairs
  end
end
