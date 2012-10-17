RedHat GIT repository
=====================

This repository and project is in no way affiliated with or supported by Red Hat, Inc. This repository is meant to provide common components to users of various provisioning methods within Red Hat technologies.

 * Application Blueprints
 * Services

How to use this repository
==========================
This repository is meant to be used as a starting point for creating application blueprints in aeolus conductor. Users can clone the GIT repoistory for using the application blueprints or contributing their application blueprints.

 Clone the repository

 # git clone https://github.com/jameslabocki/RedHat.git

 Make your changes and commit

 # git commit -m "my changes" .

 Push your changes
 
 # git push origin master


Deploying the example application blueprint
============================================

1. If you haven't already cloned the repository, clone it.

	# git clone https://github.com/jameslabocki/RedHat.git

2. At a minimum, copy the contents of the services directory to your

	# scp -r RedHat/services username@myserver:/accessible/directory

3. Within aeolus-conductor, create an application blueprint from an image which meets the required prerequisites listed in ./blueprints/example/required

4. Copy and paste the services listed in ./blueprints/example/services to the appropriate images.





Recommendations for contributing
================================

Blueprints
	This area inclues application blueprints which could be utilized in aeolus-conductor. Please include a description of your application blueprint in a file labeled README. Within the README file, please provide an overview of how the application blueprint is intended to be used. If possible, seperate reusables services into the services section for great reuse.

Services
	This area includes commonly used services that can be added to application blueprints. 





