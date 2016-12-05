[![Codacy Badge](https://api.codacy.com/project/badge/Grade/69c10a7defbe47aa91a100a12182c08e)](https://www.codacy.com/app/perth/blacklistIP?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=sc-perth/blacklistIP&amp;utm_campaign=Badge_Grade)<br/>
Usage: blacklistIP [OPTION]  [ARGUMENT]
User-friendly front-end to dropping all inbound packets from specified IPs using iptables

  [OPTION]	 [ARGUMENT]	 Descriptive statement
  -a --add	  IP[,IP[,...]]	 Drop/Block incoming packets from IP(s)
  -c --compare	  --NONE--	 Compare the current BLACKLIST chain to the saved one
  -d --load	  --NONE--	 Initializes the iptables and loads the IPs to block from
					/etc/blacklistIP/blacklistIP_save (only useful after a reboot)
  -h --help	  --NONE--	 Prints help & usage information (this message)
  -l --list	  --NONE--	 Prints list of blocked IPs in chain
  -i --import	  --NONE--	 Adds any IPs in /etc/blacklistIP/blacklistIP_save that are not currently in the chain
  -o --overwrite  --NONE--	 clears all IPs from the chain and loads all IPs in /etc/blacklistIP/blacklistIP_save
  -r --rem	  IP		 Removes IP from chain
  -s --sort	  --NONE--	 Sort the IPs in the chain
  -w --save	  --NONE--	 Saves the IPs in the chain to /etc/blacklistIP/blacklistIP_save