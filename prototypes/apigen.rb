# Generates minimal API documentation
doc_file = File.new("/tmp/sample_responses.txt", "w+")

# Initiate demo objects
u = User.new(:login => "jsmith", :full_name => "John Smith")
d = Datafile.new(:hotlinks => "--- \n:thumb: http://nuit.smugmug.com/photos/28312729_Mqavp-Ti.jpg\n:original: http://nuit.smugmug.com/photos/28312729_Mqavp-O.jpg\n:mediumthumb: http://nuit.smugmug.com/photos/28312729_Mqavp-S.jpg\n:bigthumb: http://nuit.smugmug.com/photos/28312729_Mqavp-M.jpg\n",
                 :downloaded => false)
u.save! d.save!
a = Asset.new(:title => "My awesome photo",
              :description => "This photo is pretty awesome and I took it",
              :datafile => d,
              :attachable => u)
a.save!
f = Friend.new(:name => "Chris Jones",
               :user => u)
f.save!
l = Label.new(:x => 50,
              :y => 60,
              :datafile => d,
              :friend => f)
f.labels << l
#l.save!

[u,d,a,f,l].each{ |obj|
  doc_file << "\n\n#{obj.class} sample output:\n"
  doc_file << obj.to_xml
}
doc_file.close
