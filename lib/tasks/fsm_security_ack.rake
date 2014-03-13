# -*- coding: utf-8 -*-
require 'rubygems'
require 'fsm_security_acks'

namespace :reports do

  task :fsm_security_acks => :getInvestigators do
    pi_netids = @all_investigators.map(&:username)
    puts "FSM LatticeGrid PIs = #{pi_netids.length}"

    # defines faculty_acks
    @pi_acks = faculty_acks
    puts "FSM security policy faculty acks = #{@pi_acks.length}"

    @all_pis = (pi_netids + @pi_acks).uniq
    puts "LatticeGrid PIs plus FSM security policy faculty acks = #{@all_pis.length}"
    @core_pi_acks = pi_netids & @pi_acks
    puts "only FSM security policy faculty acks who are also LatticeGrid faculty = #{@core_pi_acks.length}"
    @all_pi_noacks = pi_netids - @pi_acks
    puts "LatticeGrid faculty who have not yet acknowledged the FSM security policy = #{@all_pi_noacks.length}"
  end

  task :non_acks => :fsm_security_acks do
    puts "pis responded"
    puts "acknowledged LatticeGrid PIs count = #{@core_pi_acks.length}"
    puts "unacknowledged PIs count = #{@all_pi_noacks.length}"
    puts "unacknowledged names:"
    puts "Username\tTitle\tFull Name, FSM\tEmail, FSM\tCampus, FSM\tAppt, FSM\tDepartment, FSM\tLDAP Title\tLDAP email\tLDAP campus\tLDAP phone\tLDAP department\tLDAP Address"
    @all_pi_noacks.each do |pi_username|
      pi = Investigator.find_by_username(pi_username)
      pi_data = GetLDAPentry(pi.username)
      pi_ldap = MakePIfromLDAP(pi_data, true)
      puts "#{pi.username}\t#{pi.title}\t#{pi.full_name}\t#{pi.email}\t#{pi.campus}\t#{pi.appointment_type}\t#{pi.home_department.name unless pi.home_department_id.blank?} \t#{pi_ldap.title}\t#{pi_ldap.ldap_email}\t#{pi_ldap.campus}\t#{pi_ldap.business_phone}\t#{pi_ldap.home}\t#{pi_ldap.address1.split(13.chr).join(', ') unless pi_ldap.address1.blank?}"
    end
  end
end

