class Proposer
  def self.execute options={}
    options[:clusters] ||= 2
    options[:scorer] ||= true
    options[:pairs_to_pick] ||= 50
    Cluster.execute(options[:clusters])
    Scorer.execute if options[:scorer]
    PairPicker.execute(options[:pairs_to_pick])
  end
end
