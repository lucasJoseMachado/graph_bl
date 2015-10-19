class Edge
  def self.change_type id
    types = [%w(Car Bike), %w(Bike Car)]
    types.each do |type|
      GraphDatabase.execute_query "match a-[r:#{type[0]}]->b where id(r) = #{id} create a-[r2:#{type[1]}]->b set r2 = r"
    end
    GraphDatabase.execute_query "match a-[r]->b where id(r) = #{id} delete r"
  end
end
