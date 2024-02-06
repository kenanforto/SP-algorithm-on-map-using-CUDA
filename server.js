const express = require('express');
const app = express();
const port = 5000;
const cpp="C:\\Users\\Kenan\\Desktop\\MapaNode\\cpp\\ParallelCuda\\x64\\Debug\\ParallelCuda.exe";

const { promisify } = require('util');
const exec = promisify(require('child_process').exec)

const getShortestPath = async(cord1,cord2) => {
  // Exec output contains both stderr and stdout outputs
  const nameOutput = await exec(cpp+" "+cord1+" "+cord2)
  console.log(nameOutput.stdout.trim());
  return nameOutput.stdout.trim();

};

app.use(express.static('public'))
app.use(express.json());
// app.use((req, res, next) => {
//     res.header('Access-Control-Allow-Origin', 'http://127.0.0.1:5500');
//     res.header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE');
//     res.header('Access-Control-Allow-Headers', 'Content-Type');
//     next();
//   });
app.post('/primi-koordinate', async(req, res) => {
  const { cord1,cord2} = req.body;
  console.log('Primljene koordinate:', { cord1,cord2 });
  const result=await getShortestPath(cord1,cord2);
  console.log(result);
  const niz=JSON.parse(result);
  console.log(niz);
  res.json({ message: 'Koordinate primljene uspešno!',data:niz });
});

app.listen(port, () => {
  console.log(`Server pokrenut na: http://localhost:${port}  "`);
  // getGitUser();
});
