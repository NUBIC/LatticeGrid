# == Schema Information
# Schema version: 20130327155943
#
# Table name: investigator_colleagues
#
#  colleague_id     :integer
#  created_at       :timestamp
#  id               :integer          default(0), not null, primary key
#  in_same_program  :boolean          default(FALSE)
#  investigator_id  :integer
#  mesh_tags_cnt    :integer          default(0)
#  mesh_tags_ic     :float            default(0.0)
#  proposal_cnt     :integer          default(0)
#  proposal_list    :text
#  publication_cnt  :integer          default(0)
#  publication_list :text
#  study_cnt        :integer          default(0)
#  study_list       :text
#  tag_list         :text
#  updated_at       :timestamp
#

class InvestigatorColleague < ActiveRecord::Base
  belongs_to :investigator
  #need this for a bug in Rails 2.3.5
  belongs_to :colleague, :class_name => 'Investigator', :foreign_key => 'colleague_id'

  def publications()
    Abstract.where("abstracts.id IN (:publication_list)", { :publication_list => self.publication_list.split(",") })
      .order('abstracts.publication_date DESC, electronic_publication_date DESC, authors ASC').all
  end

  scope :mesh_ic, lambda { |*args| where('mesh_tags_ic >= :mesh_ic', { :mesh_ic => args.first }) }
  scope :shared_pubs, lambda { |*args| where('publication_cnt >= :shared_pubs', { :shared_pubs => args.first }) }

end
