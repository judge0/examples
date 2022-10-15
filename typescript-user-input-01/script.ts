function myFunction(array){
    console.log(array);
}

process.stdin.on("data", data => {
    var array = data.toString().split(",").map(i => Number(i));
    myFunction(array);
});
