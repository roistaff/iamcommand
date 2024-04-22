let apikey;
apikey = Deno.env.get("GOOGLE_AI")
console.log(apikey);
if (apikey == "\n"){
	console.log("Set up your gemini api key:")
	apikey = window.prompt("api key=>")
	Deno.set.env({ "GOOGLE_AI": apikey });
}else{
const q = window.prompt("question:")
const json = `{'prompt':{'text':'`+q+`'}}`
const response = await fetch("https://generativelanguage.googleapis.com/v1beta2/models/text-bison-001:generateText?key="+apikey, {
  method: "POST",
  body:json,
  headers: { "Content-Type": "application/json" },
});

const body = await response.json();
const obj = JSON.parse(JSON.stringify(body))
console.log(obj.candidates[0].output)
}
