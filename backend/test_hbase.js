const { exec } = require('child_process');
const util = require('util');
const execPromise = util.promisify(exec);

async function testHBaseOutput() {
  try {
    const command = `echo "get 'products', 'product#cf001'" | docker exec -i hbase /opt/hbase-1.2.6/bin/hbase shell -n`;
    console.log('Executing command:', command);
    
    const { stdout, stderr } = await execPromise(command);
    
    console.log('STDOUT:');
    console.log(stdout);
    console.log('STDERR:');
    console.log(stderr);
    
    // Split by lines and show each line
    const lines = stdout.split('\n');
    console.log('Lines:');
    lines.forEach((line, index) => {
      console.log(`${index}: "${line}"`);
    });
  } catch (error) {
    console.error('Error:', error.message);
  }
}

testHBaseOutput();