module LatticeGrid
  def LatticeGrid.the_instance
    # if "#{File.expand_path(Rails.root)}" =~ /Users/
    if Rails.env == 'development'
      'RHLCCC'
    else
      case "#{File.expand_path(Rails.root)}"
        when /fsm/i
          'Feinberg'
        when /cancer/i
          'RHLCCC'
        when /rhlccc/i
          'RHLCCC'
        when /ccne/i
          'CCNE'
        when /lls/i
          'LLS'
        when /umich/i
          'UMich'
        when /uwisc/i
          'UWCCC'
        when /stanford/i
          'Stanford'
        when /ucsf/i
          'UCSF'
        when /cinj/i
          'CINJ'
        when /uchicago/i
          'UChicago'
        when /uic/i
          'UIC'
        when /aas/i
          'AAS'
        else
          'defaults'
      end
    end
  end
end