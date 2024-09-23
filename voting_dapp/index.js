require('dotenv').config()
const express= require('express')
const app =express()
const fileUpload=require('express-fileupload')
app.use(
    fileUpload({
        extended:true
    })
)
app.use(express.static(__dirname))
app.use(express.json())
const path=require('path')
const ethers=require('ethers')

var port =3000;
const API_URL=process.env.API_URL
const PRIVATE_KEY=process.env.PRIVATE_KEY
const CONTRACT_ADDRESS=process.env.CONTRACT_ADDRESS

const {abi}= require("./artifacts/contracts/voting.sol/Voting.json")

const provider=new ethers.providers.JsonRpcProvider(API_URL)
const signer = new ethers.Wallet(PRIVATE_KEY,provider)
const contractInstance = new ethers.Contract(CONTRACT_ADDRESS,abi,signer)

app.get("/", (req,res)=>{
    res.sendFile(path.join(__dirname,"index.html"))
})
app.get("/index.html", (req,res)=>{
    res.sendFile(path.join(__dirname,"index.html"))
})

app.post("/addCandidate", async(req,res)=>{
    var candidate= req.body.candidate
    console.log(candidate)
    async function storeCandidate(candidate){
        console.log("Adding candidate")
        const tx=await contractInstance.addCandidate(candidate)
        await tx.wait()
    }
    const bool =await contractInstance.getVotingStatus()
    if(bool){
        storeCandidate(candidate)
        res.send("Candidate is registered")
    }
    else{
        res.send("Voting is finished")
    }
})


app.listen(port,function(){
    console.log("listening on port 3000")
})
