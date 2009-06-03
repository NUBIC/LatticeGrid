module GraphsHelper
  class InvestigatorNodes
    def initialize (internal,external)
      @internal = internal
      @external = external
    end
    def internal 
      @internal
    end
    def external
      @external
    end
  end

  def calculatePosition(total,theCnt)
    # assume 0,0 to 100,100
    # start at 0,0 and move around the clock.
    # 360 / total is the number of degrees per node
    
    radians_in_circle = 360/57.3
    cos = Math.cos(radians_in_circle*theCnt/total)
    sin = Math.sin(radians_in_circle*theCnt/total)
     x = 50 + (sin*45)
     y = 50 + (cos*45)
    [x,y]
  end

  def calculateInternalPosition(total,theCnt)
    # assume 0,0 to 100,100
    # start at 0,0 and move around the clock.
    # 360 / total is the number of degrees per node
    
    degrees_per_node = 360/total
    radians_per_node = degrees_per_node/57.3
    cos = Math.cos(radians_per_node*theCnt)
    sin = Math.sin(radians_per_node*theCnt)
     x = 55 + (sin*40)
     y = 50 + (cos*45)
    [x,y]
  end

  def calculateExternalPosition(total,theCnt)
    # all x=0, y=0 to 100
    
    x = 5
    y = 95-(theCnt*95/total)
    [x,y]
  end

  def internalTotal(investigators)
    total=0
    investigators.each do |inv|
      total +=1 if inv.internal_collaborators.length > 0
    end
    return total
  end

  def sortNodes(the_nodes)
    return the_nodes.sort {|x,y| y.internal_collaborators.length <=> x.internal_collaborators.length }
  end

  def rearrangeNodes(old_nodes, new_nodes, match_node=nil)
    if old_nodes.length < 1
      return new_nodes
    end
    match_node = old_nodes.shift if match_node.nil?
    new_nodes.push(match_node) if new_nodes.index( match_node ).nil?
    match_node.internal_collaborators.keys.each do |key_id|
      found_node = old_nodes.find { |i| i.id.to_i == key_id.to_i }
      logger.info 'looking for key '+key_id 
      if ! found_node.nil?
        logger.info 'found node for key '+key_id 
        new_nodes.push(found_node) if new_nodes.index( found_node ).nil?
        old_nodes.delete(found_node) 
      end
    end
    return rearrangeNodes(old_nodes, new_nodes)
  end

  def assignPositions(investigators)
    internal_nodes=Array.new(0)
    external_nodes=Array.new(0)
    investigators.each do |inv|
      if inv.internal_collaborators.length > 0
          internal_nodes[internal_nodes.length]=inv 
      else
          external_nodes[external_nodes.length]=inv 
      end
    end
    internal_nodes=sortNodes(internal_nodes)
    internal_nodes=rearrangeNodes(internal_nodes, Array.new(0))
    return InvestigatorNodes.new(internal_nodes,external_nodes)
  end

  def assignInvestigatorPositions(investigator)
    collaborator_nodes=Hash.new
    investigator.internal_collaborators.keys.each do |investigator_id|
      collaborator_nodes[investigator_id]=Investigator.find(investigator_id)
      collaborator_nodes[investigator_id]['isInternal'] = true
    end
    investigator.external_collaborators.keys.each do |investigator_id|
      collaborator_nodes[investigator_id]=Investigator.find(investigator_id)
      collaborator_nodes[investigator_id]['isInternal'] = false
    end
    return collaborator_nodes
  end
end
