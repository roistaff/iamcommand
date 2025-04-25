#!/bin/bash
ESC=$(printf '\033')
echo -n "${ESC}[33mTo computer:${ESC}[m"
prompt=$(gum input | sed -e "s/\"/\'/g")
json=$(jq -nc --arg prompt "$prompt" '{messages: [{role: "system",content: "Tell me the command to do it in terminal. output must be only one command,no explain, no markdown"},{role: "user",content: $prompt}],model: "llama3-70b-8192"}')
response=$(curl -s -X POST "https://api.groq.com/openai/v1/chat/completions" \
  -H "Authorization: Bearer $GROQ_API_KEY" \
  -H "Content-Type: application/json" \
  -d "$json")
output=$(echo $response | jq '.choices[0].message.content')
if [ "$output" = "null" ]; then
	echo $(echo "$response" | jq '.error.message')
else
##	output=$(echo $output | sed 's/^.*"\(.*\)".*$/\1/' )
	#command=$(echo $output | rev |  cut -d '$' -f 1 | cut -d '`' -f 2 | rev)
	command=$output
	gum confirm "Run ${command}?"
	if [ $? = "0" ] ; then
		eval "${command}"
	else
		echo "Failed.Try again."
	fi
fi
