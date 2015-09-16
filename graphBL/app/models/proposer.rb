class Proposer
  def self.execute options={}
    options[:clusters] ||= 2
    options[:scorer] ||= true
    options[:pairs_to_pick] ||= 50
    options[:paths_to_calculate] ||= 5
    Cluster.execute(clusters) unless clusters == false
    Scorer.execute unless scorer == false
    pairs = PairPicker.execute(pairs_to_pick)
    pairs[0..options[:paths_to_calculate]].each do |pair|
      pair["path"] = PathPlanner.execute(pair["point_a"], pair["point_b"])
    end
    return pairs
  end
end
