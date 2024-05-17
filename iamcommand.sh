#!/bin/bash
ESC=$(printf '\033')
echo -n "${ESC}[33mTo computer:${ESC}[m"
read prompt
prompt=$(echo $prompt | sed -e "s/\"/\'/g")
json=$(cat << EOS
{"messages": [{"role":"system","content":"Tell me the command to do it in terminal. output must be such '$ Command' ,and enclose by backtick."},{"role": "user", "content":"{$prompt}"}], "model": "llama3-70b-8192"}
EOS
)
echo $json | jq > $HOME/chat.json
output=$(curl -X POST "https://api.groq.com/openai/v1/chat/completions" \
  -H "Authorization: Bearer $GROQ_API_KEY" \
  -s \
  -H "Content-Type: application/json" \
  -d @$HOME/chat.json  > $HOME/answer.json && cat answer.json |  jq '.choices[0].message.content')
if [ "$output" = "null" ]; then
	echo $(cat answer.json | jq '.error.message')
else
	echo $output
	output=$(echo $output | sed 's/^.*"\(.*\)".*$/\1/' )
	echo $output
	command=$(echo $output | rev |  cut -d '$' -f 1 | cut -d '`' -f 2 | rev)
	echo $command
	read -p "Run this command? [Y/n]" yeah
	if [ $yeah = "Y" ] || [ $yeah = "y" ]; then
		echo $command > $HOME/command.sh
		./command.sh
	else
		echo "Failed.Try again."
	fi
fi
