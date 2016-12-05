<a href="https://www.codacy.com/app/perth/blacklistIP?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=sc-perth/blacklistIP&amp;utm_campaign=Badge_Grade"><img src="https://api.codacy.com/project/badge/Grade/69c10a7defbe47aa91a100a12182c08e"/></a><br/>

Usage: blacklistIP [OPTION] [ARGUMENT]<br/>
User-friendly front-end to dropping all inbound packets from specified IPs using iptables<br/>
<br/>
<table>
  <tr>
    <td>[OPTION]</td>
    <td>[ARGUMENT]</td>
    <td>Descriptive statement</td>
  </tr>
  <tr>
    <td>-a --add</td>
    <td>IP[,IP[,...]]</td>
    <td>Drop/Block incoming packets from IP(s)</td>
  </tr>
  <tr>
    <td>-c --compare</td>
    <td>--NONE--</td>
    <td>Compare the current BLACKLIST chain to the saved one</td>
  </tr>
  <tr>
    <td>-d --load</td>
    <td>--NONE--</td>
    <td>Initializes the iptables and loads the IPs to block from<br/>
        &nbsp&nbsp/etc/blacklistIP /blacklistIP_save (only useful after a reboot)</td>
  </tr>
  <tr>
    <td>-h --help</td>
    <td>--NONE--</td>
    <td>help &amp usage information (this message)</td>
  </tr>
  <tr>
    <td>-l --list</td>
    <td>--NONE--</td>
    <td>Prints list of blocked IPs in chain</td>
  </tr>
  <tr>
    <td>-i --import</td>
    <td>--NONE--</td>
    <td>Adds any IPs in /etc/blacklistIP/blacklistIP_save that are not currently in the chain</td>
  </tr>
  <tr>
    <td>-o --overwrite</td>
    <td>--NONE--</td>
    <td>clears all IPs from the chain and loads all IPs in /etc/blacklistIP/blacklistIP_save</td>
  </tr>
  <tr>
    <td>-r --rem</td>
    <td>IP</td>
    <td>Removes IP from chain</td>
  </tr>
  <tr>
    <td>-s --sort</td>
    <td>--NONE--</td>
    <td>Sort the IPs in the chain</td>
  </tr>
  <tr>
    <td>-w --save</td>
    <td>--NONE--</td>
    <td>Saves the IPs in the chain to /etc/blacklistIP/blacklistIP_save</td>
  </tr>
</table>
