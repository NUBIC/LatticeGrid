# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20140124011303) do

  create_table "abstracts", :force => true do |t|
    t.text      "endnote_citation"
    t.text      "abstract"
    t.text      "authors"
    t.text      "full_authors"
    t.boolean   "is_first_author_investigator", :default => false
    t.boolean   "is_last_author_investigator",  :default => false
    t.text      "title"
    t.string    "journal_abbreviation"
    t.string    "journal"
    t.string    "volume"
    t.string    "issue"
    t.string    "pages"
    t.string    "year"
    t.date      "publication_date"
    t.string    "publication_type"
    t.date      "electronic_publication_date"
    t.date      "deposited_date"
    t.string    "status"
    t.string    "publication_status"
    t.string    "pubmed"
    t.string    "issn"
    t.string    "isbn"
    t.integer   "citation_cnt",                 :default => 0
    t.timestamp "citation_last_get_at"
    t.string    "citation_url"
    t.string    "url"
    t.text      "mesh"
    t.integer   "created_id"
    t.string    "created_ip"
    t.integer   "updated_id"
    t.string    "updated_ip"
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.boolean   "is_cancer",                    :default => true,  :null => false
    t.string    "pubmedcentral"
    t.text      "vectors"
    t.boolean   "is_valid",                     :default => true,  :null => false
    t.timestamp "reviewed_at"
    t.integer   "reviewed_id"
    t.string    "reviewed_ip"
    t.timestamp "last_reviewed_at"
    t.integer   "last_reviewed_id"
    t.string    "last_reviewed_ip"
    t.date      "pubmed_creation_date"
    t.string    "doi"
    t.text      "author_affiliations"
    t.text      "author_vector"
    t.text      "abstract_vector"
    t.text      "mesh_vector"
    t.text      "journal_vector"
  end

  add_index "abstracts", ["abstract_vector"], :name => "abstracts_fts_abstract_vector_index"
  add_index "abstracts", ["author_vector"], :name => "abstracts_fts_author_vector_index"
  add_index "abstracts", ["journal_vector"], :name => "abstracts_fts_journal_vector_index"
  add_index "abstracts", ["mesh_vector"], :name => "abstracts_fts_mesh_vector_index"
  add_index "abstracts", ["pubmed", "doi"], :name => "by_pubmed_doi_unique", :unique => true
  add_index "abstracts", ["vectors"], :name => "abstracts_fts_vectors_index"

  create_table "investigator_abstracts", :force => true do |t|
    t.integer   "abstract_id",                         :null => false
    t.integer   "investigator_id",                     :null => false
    t.boolean   "is_first_author",  :default => false, :null => false
    t.boolean   "is_last_author",   :default => false, :null => false
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.boolean   "is_valid",         :default => false, :null => false
    t.timestamp "reviewed_at"
    t.integer   "reviewed_id"
    t.string    "reviewed_ip"
    t.timestamp "last_reviewed_at"
    t.integer   "last_reviewed_id"
    t.string    "last_reviewed_ip"
    t.date      "publication_date"
  end

  add_index "investigator_abstracts", ["abstract_id", "investigator_id"], :name => "by_asbtract_investigator_unique", :unique => true

  create_table "investigator_appointments", :force => true do |t|
    t.integer   "organizational_unit_id", :null => false
    t.integer   "investigator_id",        :null => false
    t.string    "type"
    t.date      "start_date"
    t.date      "end_date"
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.text      "research_summary"
  end

  add_index "investigator_appointments", ["organizational_unit_id", "investigator_id", "type"], :name => "by_unit_investigator_unique", :unique => true

  create_table "investigator_colleagues", :force => true do |t|
    t.integer   "investigator_id"
    t.integer   "colleague_id"
    t.integer   "mesh_tags_cnt",    :default => 0
    t.float     "mesh_tags_ic",     :default => 0.0
    t.text      "tag_list"
    t.integer   "publication_cnt",  :default => 0
    t.text      "publication_list"
    t.boolean   "in_same_program",  :default => false
    t.integer   "proposal_cnt",     :default => 0
    t.text      "proposal_list"
    t.integer   "study_cnt",        :default => 0
    t.text      "study_list"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  add_index "investigator_colleagues", ["colleague_id", "investigator_id", "mesh_tags_ic"], :name => "by_colleague_mesh_ic"
  add_index "investigator_colleagues", ["colleague_id", "investigator_id", "publication_cnt"], :name => "by_colleague_pubs"
  add_index "investigator_colleagues", ["colleague_id", "investigator_id"], :name => "by_colleague_investigator", :unique => true
  add_index "investigator_colleagues", ["mesh_tags_ic"], :name => "mesh_tags_ic"

  create_table "investigator_proposals", :force => true do |t|
    t.string    "role"
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.integer   "investigator_id",                    :null => false
    t.integer   "proposal_id",                        :null => false
    t.integer   "percent_effort",  :default => 0
    t.boolean   "is_main_pi",      :default => false, :null => false
  end

  create_table "investigator_studies", :force => true do |t|
    t.string    "status"
    t.date      "approval_date"
    t.date      "completion_date"
    t.string    "role"
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.integer   "investigator_id", :null => false
    t.integer   "study_id",        :null => false
    t.string    "consent_role"
  end

  create_table "investigators", :force => true do |t|
    t.string    "username",                                                                    :null => false
    t.string    "last_name",                                                                   :null => false
    t.string    "first_name",                                                                  :null => false
    t.string    "middle_name"
    t.string    "email"
    t.string    "degrees"
    t.string    "suffix"
    t.integer   "employee_id"
    t.string    "title"
    t.integer   "home_department_id"
    t.string    "campus"
    t.string    "appointment_type"
    t.string    "appointment_track"
    t.string    "appointment_basis"
    t.string    "pubmed_search_name"
    t.boolean   "pubmed_limit_to_institution",                              :default => false
    t.integer   "num_first_pubs_last_five_years",                           :default => 0
    t.integer   "num_last_pubs_last_five_years",                            :default => 0
    t.integer   "total_publications_last_five_years",                       :default => 0
    t.integer   "num_intraunit_collaborators_last_five_years",              :default => 0
    t.integer   "num_extraunit_collaborators_last_five_years",              :default => 0
    t.integer   "num_first_pubs",                                           :default => 0
    t.integer   "num_last_pubs",                                            :default => 0
    t.integer   "total_publications",                                       :default => 0
    t.integer   "num_intraunit_collaborators",                              :default => 0
    t.integer   "num_extraunit_collaborators",                              :default => 0
    t.date      "last_pubmed_search"
    t.string    "mailcode"
    t.text      "address1"
    t.string    "address2"
    t.string    "city"
    t.string    "state"
    t.string    "postal_code"
    t.string    "country"
    t.string    "business_phone"
    t.string    "home_phone"
    t.string    "lab_phone"
    t.string    "fax"
    t.string    "pager"
    t.string    "ssn",                                         :limit => 9
    t.string    "sex",                                         :limit => 1
    t.date      "birth_date"
    t.date      "nu_start_date"
    t.date      "start_date"
    t.date      "end_date"
    t.integer   "weekly_hours_min",                                         :default => 35
    t.timestamp "last_successful_login"
    t.timestamp "last_login_failure"
    t.integer   "consecutive_login_failures",                               :default => 0
    t.string    "password"
    t.timestamp "password_changed_at"
    t.integer   "password_changed_id"
    t.string    "password_changed_ip"
    t.integer   "created_id"
    t.string    "created_ip"
    t.integer   "updated_id"
    t.string    "updated_ip"
    t.timestamp "deleted_at"
    t.integer   "deleted_id"
    t.string    "deleted_ip"
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.text      "faculty_keywords"
    t.text      "faculty_research_summary"
    t.text      "faculty_interests"
    t.text      "vectors"
    t.integer   "total_studies",                                            :default => 0,     :null => false
    t.integer   "total_studies_collaborators",                              :default => 0,     :null => false
    t.integer   "total_pi_studies",                                         :default => 0,     :null => false
    t.integer   "total_pi_studies_collaborators",                           :default => 0,     :null => false
    t.integer   "total_awards",                                             :default => 0,     :null => false
    t.integer   "total_awards_collaborators",                               :default => 0,     :null => false
    t.integer   "total_pi_awards",                                          :default => 0,     :null => false
    t.integer   "total_pi_awards_collaborators",                            :default => 0,     :null => false
    t.string    "home_department_name"
    t.string    "era_comons_name"
  end

  add_index "investigators", ["era_comons_name"], :name => "by_era_comons_name_unique", :unique => true
  add_index "investigators", ["faculty_keywords", "faculty_interests"], :name => "by_keywords_summary_interests"
  add_index "investigators", ["username"], :name => "index_investigators_on_username", :unique => true
  add_index "investigators", ["vectors"], :name => "investigators_fts_vectors_index"

  create_table "journals", :force => true do |t|
    t.string    "journal_name"
    t.string    "journal_abbreviation",                        :null => false
    t.string    "jcr_journal_abbreviation"
    t.string    "issn"
    t.integer   "score_year"
    t.integer   "total_cites"
    t.float     "impact_factor"
    t.float     "impact_factor_five_year"
    t.float     "immediacy_index"
    t.integer   "total_articles"
    t.float     "eigenfactor_score"
    t.float     "article_influence_score"
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.boolean   "include_as_high_impact",   :default => false, :null => false
  end

  add_index "journals", ["journal_abbreviation"], :name => "index_journals_on_journal_abbreviation", :unique => true

  create_table "load_dates", :force => true do |t|
    t.timestamp "load_date"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  add_index "load_dates", ["load_date"], :name => "index_load_dates_on_load_date", :unique => true

  create_table "logs", :force => true do |t|
    t.string    "activity"
    t.integer   "investigator_id"
    t.integer   "program_id"
    t.string    "controller_name"
    t.string    "action_name"
    t.text      "params"
    t.string    "created_ip"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  create_table "organization_abstracts", :force => true do |t|
    t.integer   "organizational_unit_id", :null => false
    t.integer   "abstract_id",            :null => false
    t.date      "start_date"
    t.date      "end_date"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  add_index "organization_abstracts", ["organizational_unit_id", "abstract_id"], :name => "by_unit_abstract_unique", :unique => true

  create_table "organizational_units", :force => true do |t|
    t.string    "name",                                       :null => false
    t.string    "search_name"
    t.string    "abbreviation"
    t.string    "campus"
    t.string    "organization_url"
    t.string    "type",                                       :null => false
    t.string    "organization_classification"
    t.string    "organization_phone"
    t.integer   "department_id",               :default => 0, :null => false
    t.integer   "division_id",                 :default => 0
    t.integer   "member_count",                :default => 0
    t.integer   "appointment_count",           :default => 0
    t.integer   "lft"
    t.integer   "rgt"
    t.integer   "children_count",              :default => 0
    t.integer   "sort_order",                  :default => 1
    t.integer   "parent_id"
    t.integer   "depth",                       :default => 0
    t.date      "start_date"
    t.date      "end_date"
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.string    "pubmed_search_name"
  end

  add_index "organizational_units", ["department_id", "division_id"], :name => "index_organizational_units_on_department_id_and_division_id", :unique => true

  create_table "proposals", :force => true do |t|
    t.string    "sponsor_award_number"
    t.string    "sponsor_code"
    t.string    "sponsor_name"
    t.string    "institution_award_number"
    t.string    "title"
    t.text      "abstract"
    t.text      "keywords"
    t.string    "agency"
    t.date      "submission_date"
    t.date      "project_start_date"
    t.date      "project_end_date"
    t.boolean   "is_awarded",                      :default => true
    t.string    "award_category"
    t.string    "award_mechanism"
    t.string    "award_type"
    t.string    "url"
    t.integer   "created_id"
    t.string    "created_ip"
    t.integer   "updated_id"
    t.string    "updated_ip"
    t.timestamp "deleted_at"
    t.integer   "deleted_id"
    t.string    "deleted_ip"
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.date      "award_start_date"
    t.date      "award_end_date"
    t.integer   "direct_amount"
    t.integer   "indirect_amount"
    t.integer   "total_amount"
    t.string    "sponsor_type_name"
    t.string    "sponsor_type_code"
    t.string    "original_sponsor_name"
    t.string    "original_sponsor_code"
    t.string    "pi_employee_id"
    t.string    "parent_institution_award_number"
    t.boolean   "merged",                          :default => false
  end

  create_table "studies", :force => true do |t|
    t.text      "title"
    t.text      "abstract"
    t.string    "sponsor"
    t.string    "nct_id"
    t.integer   "accrual_goal"
    t.date      "approved_date"
    t.date      "closed_date"
    t.date      "completed_date"
    t.string    "status"
    t.string    "url"
    t.integer   "created_id"
    t.string    "created_ip"
    t.integer   "updated_id"
    t.string    "updated_ip"
    t.timestamp "deleted_at"
    t.integer   "deleted_id"
    t.string    "deleted_ip"
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.integer   "enotis_study_id"
    t.string    "irb_study_number"
    t.string    "research_type"
    t.string    "review_type"
    t.integer   "proposal_id"
    t.boolean   "is_clinical_trial",    :default => false, :null => false
    t.text      "inclusion_criteria"
    t.text      "exclusion_criteria"
    t.boolean   "has_medical_services", :default => false, :null => false
    t.boolean   "had_import_errors",    :default => false
    t.date      "next_review_date"
  end

  add_index "studies", ["enotis_study_id"], :name => "study_by_enotis_study_id_uq", :unique => true
  add_index "studies", ["irb_study_number"], :name => "study_by_irb_study_number_uq", :unique => true

  create_table "taggings", :force => true do |t|
    t.integer   "tag_id"
    t.integer   "taggable_id"
    t.float     "information_content", :default => 0.0
    t.string    "taggable_type"
    t.timestamp "created_at"
  end

  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id", "taggable_type"], :name => "index_taggings_on_taggable_id_and_taggable_type"

  create_table "tags", :force => true do |t|
    t.string "name"
  end

  create_table "word_frequencies", :force => true do |t|
    t.integer   "frequency"
    t.string    "word"
    t.string    "the_type"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  add_index "word_frequencies", ["word", "the_type"], :name => "by_word_type_unique", :unique => true
  add_index "word_frequencies", ["word"], :name => "by_word"

end
