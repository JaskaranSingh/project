#####################################################################
#                "Welcome to BaKaPlan installation script"          #
#  Discription: This script checks the internet connectivity        # 
#                and starts the installation.			    #                               
#                                                                   #   		       
#                                                                   #  		       
# Please read AutoInstall.txt file before you run this script       #  		       
#                                                                   #  		       
#      Author   :  Jaskaran Singh Lamba, lamba.jaskaran@gmail.com   #     	       
#      License  :  GNU General Public License                       #   		      
#      Copyright:  Copyright (c) 2013, Great Developers             #  		       
#                                                                   #  		       
#      created : 13-July-2013                                       #  		       
#      last update : 12-July-2013                                   #  		       
#      VERSION=0.1                                                  # 		       
#                                                                   #  		       
#####################################################################

read -p "Enter your system username:" username
read -sp "Enter your password:" password

clear
    echo ""
    echo "######################################################"
    echo "#                                                    #"
    echo "#    CHECKING---Internet Connection---               #"
    echo "#                                                    #"
    echo "######################################################"
    echo ""

packet_loss=$(ping -c 5 -q 202.164.53.116 | grep -oP '\d+(?=% packet loss)')
if [ $packet_loss -ge 50 ]; then

    echo "::::::::::::SLOW or NO INTERNET CONNECTION:::::::::::::"
    echo "Please check your connectivity and try again later."
    exit
else
     echo "::::::::::::INTERNET IS WORKING PROPERLY::::::::::::"
fi

##########################################
#                                        #
#      :::::: Restarts Apache ::::::     # 
#                                        #
##########################################

restart_func()
{
    echo $password | sudo service apache2 restart               
}


##########################################
#                                        #
#       Function to clone BaKaPlan       # 
#                                        #
##########################################


baka_func()
{
   
    cd ~/public_html/cgi-bin
    if [ -d "bakaplan" ]; then
        echo "A Directory named 'bakaplan' already exists"
        read -p "Do you want to delete it and clone again (y/n)?" ans

    if [ $ans = y ] || [ $ans = Y ]; then
        a=1 

        while [ $a -ne 2 ]
        do
 
            read -p "Enter your mysql username:" db_user  
            read -sp "Enter your mysql password:" db_password
            echo ""

            RESULT=`mysql --user="$db_user" --password="$db_password"\
            --skip-column-names -e "SHOW DATABASES LIKE 'mysql'"`
            if [ $RESULT ]; then
                echo ""
                echo "Username and Password Matches"
                 a=`expr $a + 1`
                 break
                 
            else
 
                 echo ""
                 echo "Username and Password don't match"
                 echo "re-enter the details"
                 echo ""
                 
            fi
         done
       
            a=1 

        while [ $a -ne 2 ]
        do
            read -p "Enter database name:" db
 
             RESULT=`mysql --user="$db_user" --password="$db_password" \
                   --skip-column-names -e "SHOW DATABASES LIKE '$db'"`
             if [ $RESULT ]; then
                echo "The Database exist, choose another name for database."
                read -p "Enter database name again:" db
             else
                 break
            fi
        done
      echo $password | sudo rm -r bakaplan
      rm -r bp
      rm -r ~/public_html/BaKaPlan	
      rm -r ~/public_html/SeatPlan
      
      echo ""
      echo "######################################################"
      echo "#                                                    #"
      echo "#     :::::::::CLONING BaKaPlan::::::::::            #"
      echo "#                                                    #"
      echo "######################################################"
      echo ""

      cd ~/public_html/cgi-bin
      git clone https://github.com/GreatDevelopers/bakaplan.git
    
      cd bakaplan/frontend/src/header
    
      echo "Modifying 'database-detail.h' file"
      sed -i 's/USER "DATABASE_USERNAME"/USER '\"$db_user\"'/' database-detail.h
      sed -i 's/PASSWORD "DATABASE_PASSWORD"/PASSWORD '\"$db_password\"'/' database-detail.h 
      sed -i 's/DATABASE "DATABASE_NAME"/DATABASE '\"$db\"'/' database-detail.h

      echo "Modifying 'sendmail-detail.h' file"
    
      cd ~/public_html/cgi-bin/bakaplan/frontend/src/header

      read -p "enter your email id:" user_id
      read -p "enter your server(type localhost or the IP): " server

      sed -i 's/"USER_EMAIL_ID"/'\"$user_id\"'/' sendmail-detail.h    
      sed -i 's/"LOCALHOST_OR_SERVER_IP"/'\"$server\"'/' sendmail-detail.h
      sed -i 's/SYSTEM_USERNAME/'$username'/' sendmail-detail.h

      cd ~/public_html/cgi-bin/bakaplan
      make install
      mysqlbash_path='/usr/bin/mysql'                            	  
      mysqlbash="$mysqlbash_path --user=$db_user --password=$db_password -e" 
      $mysqlbash "create database $db "                          	 
  
    cd ~/public_html/cgi-bin/bakaplan/database
    mysql --user=$db_user --password=$db_password $db < bakaplan.sql 
   
    else 
        echo ""
    fi
    else
        a=1 
        while [ $a -ne 2 ]
        do
            read -p "Enter your mysql username:" db_user       
            read -sp "Enter your mysql password:" db_password
            echo ""

            RESULT=`mysql --user="$db_user" --password="$db_password"\
            --skip-column-names -e "SHOW DATABASES LIKE 'mysql'"`
            if [ $RESULT ]; then
                 echo ""
                 echo "Username and Password Matches"
                 a=`expr $a + 1`
                 break
            else
                 echo ""
                 echo "Password doesn't match"
                 echo "re-enter the details"
                 echo ""
 
            fi
        done
        a=1 

        while [ $a -ne 2 ]
        do
             read -p "Enter database name:" db
             
             RESULT=`mysql --user="$db_user" --password="$db_password" \
                   --skip-column-names -e "SHOW DATABASES LIKE '$db'"`
                   if [ $RESULT ]; then
                        echo "The Database exist, choose another name 
                        for database."
                        echo ""
                   else
                        break
                   fi
        done 

          echo ""
          echo "######################################################"
          echo "#                                                    #"
          echo "#     :::::::::CLONING BaKaPlan::::::::::            #"
          echo "#                                                    #"
          echo "######################################################"
          echo ""

          cd ~/public_html/cgi-bin
          git clone https://github.com/GreatDevelopers/bakaplan.git
            
          echo "Modifying 'database-detail.h' file"
          cd bakaplan/frontend/src/header
          sed -i 's/USER "DATABASE_USERNAME"/USER '\"$db_user\"'/' database-detail.h
          sed -i 's/PASSWORD "DATABASE_PASSWORD"/PASSWORD '\"$db_password\"'/' database-detail.h 
          sed -i 's/DATABASE "DATABASE_NAME"/DATABASE '\"$db\"'/' database-detail.h

           
          echo "Modifying 'sendmail-detail.h' file"
          
          cd ~/public_html/cgi-bin/bakaplan/frontend/src/header
          read -p "enter your email id:" user_id
          read -p "enter your server(type localhost or the IP): " server
         
          sed -i 's/"USER_EMAIL_ID"/'\"$user_id\"'/' sendmail-detail.h    
          sed -i 's/"LOCALHOST_OR_SERVER_IP"/'\"$server\"'/' sendmail-detail.h
          sed -i 's/SYSTEM_USERNAME/'$username'/' sendmail-detail.h
          
          cd ~/public_html/cgi-bin/bakaplan
          make install
            
          mysqlbash_path='/usr/bin/mysql'                            	  
          mysqlbash="$mysqlbash_path --user=$db_user --password=$db_password -e" 
          $mysqlbash "create database $db "                          	 
        
          cd ~/public_html/cgi-bin/bakaplan/database
           mysql --user=$db_user --password=$db_password $db < bakaplan.sql
    fi
  
}


##########################################
#                                        #
#       Function to install git          # 
#                                        #
##########################################


git_func()
{
    result=$(dpkg-query -W -f='${package}\n' "git")
    if  [ $result = git ]; then
        
        echo "Git already installed"
        baka_func
    else
	    echo "Git is not installed in your system"
        echo "Installing Git"
	    echo $password | sudo -S apt-get install -y  git
        baka_func
    fi
}


##########################################
#                                        #
#     :::::: Installs Exim4 ::::::       # 
#                                        #
##########################################


exim_func()
{
    
        clear
	    read -p "Enter your email usernamep(USERNAME@example.com):" e_user
        read -sp "Enter your email password:" e_password
        clear
        echo ":::::::::: Attention::::::::::"
        echo "\n\nExim installation starting"
        echo "A file will open shortly"
        echo "Follow the instructions to complete exim installation"
        sleep 5s
	    echo $password | sudo rm -rf /var/lib/dpkg/lock
        echo $password | sudo apt-get install -y exim4
        xterm -e gedit ~/project/script/exim.txt
        echo $password | sudo dpkg-reconfigure exim4-config
        echo $password | sudo chmod -R 777 /etc/exim4/passwd.client
        cd /etc/exim4
        echo "*:$e_user:$e_password" >> passwd.client
        git_func
}       



##########################################
#                                        #
#  :::::: Installs PDF Library ::::::    # 
#                                        #
##########################################


hpdf_func()
{
 
    cd /usr/local/include

    if [ -f "hpdf.h" ] && [ -f "hpdf_pages.h" ] \
                   && [ -f "hpdf_config.h" ];
        then
        echo "HPDF Library already intsalled"
        exim_func
    else
        cd ~/Downloads
        if [ -f "master" ];
            then
             rm master
             rm -r libharu-libharu-22e741e
             wget https://github.com/libharu/libharu/tarball/master
             tar -xzf master
             cd libharu-libharu-22e741e
             echo $password | sudo apt-get install -y cmake
             cmake -G 'Unix Makefiles' 
             make
             echo $password | sudo make install

        else
             wget https://github.com/libharu/libharu/tarball/master
             tar -xzf master
             cd libharu-libharu-22e741e
             echo $password | sudo apt-get install -y cmake
             cmake -G 'Unix Makefiles' 
             make
             echo $password | sudo make install

        fi
        exim_func
    fi
 
}

##########################################
#                                        #
#   Fucntion to install jwsmtp library   # 
#                                        #
##########################################


Install_jwsmtp()
{
    cd /usr/local/include

    if [ -d "jwsmtp-1.32" ]
        then
        echo "JWSMTP Library already intsalled"
        hpdf_func
    else
        cd ~/Downloads
        if [ -f "jwsmtp-1.32.15.tar.gz" ]
            then
            rm jwsmtp-1.32.15.tar.gz
            rm -r jwsmtp-1.32.15
            wget http://bit.ly/12Qgslq
            mv 12Qgslq jwsmtp-1.32.15.tar.gz
            tar -xzf jwsmtp-1.32.15.tar.gz
            cd jwsmtp-1.32.15/jwsmtp
            sed -i '29i#include<cstring>' demo2.cpp
            cd jwsmtp
            sed -i '37i#include<cstring>' mailer.cpp
            cd ../..
            ./configure
            make
            echo $password | sudo make install   

        else
             wget http://bit.ly/12Qgslq
             mv 12Qgslq jwsmtp-1.32.15.tar.gz
             tar -xzf jwsmtp-1.32.15.tar.gz
             cd jwsmtp-1.32.15/jwsmtp
             sed -i '29i#include<cstring>' demo2.cpp
             cd jwsmtp
             sed -i '37i#include<cstring>' mailer.cpp
             cd ../..
             ./configure
             make
             echo $password | sudo make install   
        fi
        hpdf_func
    fi  
}


##########################################
#                                        #
#   Function to install boost library    # 
#                                        #
##########################################


boost()
{
    result=$(dpkg-query -W -f='${package}\n' "libboost1.49-dev")
    if  [ $result = libboost1.49-dev ] 
        then
        echo "Boost library already installed"
        Install_jwsmtp
    else
	    echo "Boost library is not installed in your system"
        echo "Installing Boost library"
	    echo $password | sudo -S apt-get install -y libboost1.49-dev
       Install_jwsmtp
    fi
}


####################################################
#                                                  #
#    Function to install mysql server and client   # 
#                                                  #
####################################################


Install_mysql()
{
    result=$(dpkg-query -W -f='${package}\n' "mysql-server")
    if  [ $result = mysql-server ] 
        then
        echo "mysql-server already installed"
    else
	    echo "mysql-server is not installed in your system"
        echo "Installing mysql-server library"
	    echo $password | sudo -S apt-get install -y mysql-server
    fi
    
    result=$(dpkg-query -W -f='${package}\n' "mysql-client")
    if  [ $result = mysql-client ]
         then
        echo "mysql-client already installed"
        echo "Installing libmysql++ and libmysql++-dev"
    else
	    echo "mysql-client is not installed in your system"
        echo "Installing mysql-client library"
	    echo $password | sudo -S apt-get install -y mysql-client
    fi
    
    result=$(dpkg-query -W -f='${package}\n' "libmysql++-dev")
    if  [ $result = libmysql++-dev ] 
        then
        echo "libmysql++-dev and libmysql++ already installed"
        boost    
    else
	    echo "libmyqsql++-dev and libmysql++ are not installed in your system"
        echo "Installing libmysql++-dev and libmysql++"
	    echo $password | sudo -S apt-get install -y libmysql++-dev libmysql++
        boost    
    fi
}


##########################################
#                                        #
#   Function to install cgicc library    # 
#                                        #
##########################################


cgicc_func()
{
    cd /usr/include/cgicc
    if [ -f "Cgicc.h" ]; then
    	echo "cgicc library exists"
	Install_mysql
    else
     	cd ~/Downloads
        wget http://ftp.gnu.org/gnu/cgicc/cgicc-3.2.10.tar.gz
        tar xzf cgicc-3.2.10.tar.gz 
        cd cgicc-3.2.10/
        ./configure --prefix=/usr
        make
        echo $password | sudo -S make install
        Install_mysql
    fi
}

###############################################
#                                             #
#   Function to configure cgi in public_html  # 
#                                             #
###############################################


cgi_func()
{
    cd /home/jaskaran
    echo "Configuring home directory"
    echo "Checking and creating public_html"
    if [ -d "public_html" ]; then
        echo "public_html directory already exists"
    else
        mkdir ~/public_html
        echo $password | sudo -S a2enmod userdir
        restart_func
    fi
     
    echo "Giving permissions"
    chmod -R 755 ~/public_html

    echo "Configuring cgi in public_html"
    echo $password | sudo -S a2enmod cgi
    echo $password | sudo -S a2enmod cgid
    restart_func
    
    echo "Checking and creating directory cgi-bin"
    cd ~/public_html
    if [ -d "cgi-bin" ]; then
        echo "cgi-bin directory already exists"
    else
        mkdir cgi-bin
    fi
    
    cd /etc/apache2/sites-available
    echo $password | sudo -S chmod -R 777 default
    if grep -q '/public_html/cgi-bin' default
        then
        cgicc_func
    else
        echo ScriptAlias /cgi-bin/ /home/*/public_html/cgi-bin/  >> default
        echo "<Directory \"/home/*/public_html/cgi-bin\">" >> default
        echo AllowOverride None >> default
        echo Options +ExecCGI -MultiViews +SymLinksIfOwnerMatch >> default
        echo SetHandler cgi-script >> default
        echo Order allow,deny >> default
        echo Allow from all >> default
        echo "</Directory>" >> default 
        restart_func
        cgicc_func
    fi
}

#############################################
#                                           #
#   Function to install apache webserver    # 
#                                           #
#############################################


Install_apache()
{
    result=$(dpkg-query -W -f='${package}\n' "apache2")
    if  [ $result = apache2 ]
        then
        echo "apache2 webserver already installed"
        cgi_func
    else
	    echo "apache2 is not installed in your system"
        echo "Installing apache2"
	    echo $password | sudo -S apt-get install -y apache2
      	cgi_func
    fi
}


##########################################
#                                        #
#   Function to install GCC compiler     # 
#                                        #
##########################################


Install_compiler()
{
    result=$(dpkg-query -W -f='${package}\n' "g++")
    if  [ $result = g++ ]
        then
        echo "GNU g++ compiler already installed"
        Install_apache
    else
     	echo "GNU g++ is not installed in your system"
        echo "Installing GNU g++"
        echo $password | sudo -S apt-get install -y g++
      	Install_apache
    fi
}

Install_compiler
echo $password | sudo -S ln -s /usr/local/lib/libjwsmtp-1.32.so \
     /usr/lib/libjwsmtp-1.32.so
cd ~/public_html/cgi-bin/bakaplan
make
firefox http://localhost/~$username/cgi-bin/bp/login
