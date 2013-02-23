#!/usr/bin/ruby

require 'rubygems'
require 'rest_client'
require 'net/http'
require 'rexml/document'
include REXML

#Change these for your environment
myrhevm = 'rhevm.yourdomain.com'
myurl = 'https://' + myrhevm + '/api/vms'
myuser = 'admin@internal'
mypass = 'yourpass'
hostprefix = 'ecm'
domain = 'yourdomain.com'
ipprefix = '10.16.132'

print "This script will create virtual machines based on a template in the following RHEV environment: " + myurl + "\n" + "It will also overwrite any static DHCP reservations in /etc/dhcp/labreservations.conf\n"

print "Do you want to continue? <yes/no> : "
mycontinue = gets.chomp

if mycontinue != "yes"
	exit
end

print "Excellent, lets get started ...\n"

print "Which cluster would you like to build the VMs on? "
mycluster = gets.chomp

print "What is the template name you would like to use? [Use Blank for none] "
mytemplate = gets.chomp

print "How many virtual machines should we create? "
mynumber = gets.to_i

print "============= Summary of Action ===========\n"
print "== RHEV Environment: " + myurl + "\n"
print "== Cluster:          " + mycluster + "\n"
print "== Template:         " + mytemplate + "\n"
print "== Number:           #{mynumber} \n"
print "===========================================\n"
print "continue? <yes/no> : " 
mycontinue2 = gets.chomp

#Write out header to dhcp.conf include file
File.open('/etc/dhcp/labreservations.conf', 'w') do |f2|
	f2.puts "### Written by automaterbuild.rb, all changes will be overwritten\n"
end

if mycontinue2 != "yes"
        exit
end

basenumber = 50 
mynumber +=50
totalnumber = mynumber - 1

while basenumber != mynumber  do
   puts("Building " + hostprefix + "#{basenumber} of " + hostprefix + "#{totalnumber}" )

	#Create a connection
	resource = RestClient::Resource.new(myurl, :user => myuser, :password => mypass)

	#Create a VM
	createvm = resource.post "<vm><name>" + hostprefix + "#{basenumber}</name><cluster><name>" + mycluster + "</name></cluster><template><name>" + mytemplate + "</name></template><memory>4294967296</memory><os><boot dev='hd'/></os></vm>", :content_type => 'application/xml', :accept => 'application/xml'

	#print output
	#print createvm

	#extract virtual machine and nic details from the createvm
	createvmdoc = REXML::Document.new(createvm)
	root = createvmdoc.root
	myvmid = root.attributes["id"]
	#print "\n\n vmid: " + myvmid + " \n\n"

	myvmurl = "https://" + myrhevm + "/api/vms/" + myvmid + "/nics"
	myvmresource = RestClient::Resource.new(myvmurl, :user => myuser, :password => mypass)

	myvmresourceoutput = myvmresource.get
	#print myvmresourceoutput

	vmnicdoc = REXML::Document.new(myvmresourceoutput)
	root = vmnicdoc.root
	myvmnicid = root.elements[1].attributes["id"]
	#print "\n\n vmnicid: \n\n"
	
	myvmnicurl = "https://" + myrhevm + "/api/vms/" + myvmid + "/nics/" + myvmnicid
	myvmnicresource = RestClient::Resource.new(myvmnicurl, :user => myuser, :password => mypass)

	myvmnicresourceoutput = myvmnicresource.get
	#print "\n\n myvmnicresource.get \n\n"
	#print myvmnicresourceoutput
	
	vmnicdetaildoc = REXML::Document.new(myvmnicresourceoutput)
	root = vmnicdetaildoc.root
	myvmnicmac = root.elements["mac"].attributes["address"]

	#Add Entry to dhcp.conf include file to give static reservation matching hostname
	File.open('/etc/dhcp/labreservations.conf', 'a') do |f2|
  		f2.puts "host " + hostprefix + "#{basenumber}." + domain + " {\n"
		#no longer used
		#f2.puts "   hardware ethernet 00:1A:4A:10:85:#{hexnum};\n"
		f2.puts "   hardware ethernet " + myvmnicmac + ";\n"
		f2.puts "   fixed-address " + ipprefix + ".#{basenumber};\n"
		f2.puts "}\n\n"
	end
 
   basenumber +=1

end

print "completed building hosts. Please check /etc/dhcp/labreservations.conf for DHCP leases\n"
print "restart dhcp? <yes/no>"
mydhcprestart = gets.chomp

if mydhcprestart != "yes"
        exit
end

system('/etc/init.d/dhcpd restart')



