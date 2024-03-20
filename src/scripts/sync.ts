import ghPages from "gh-pages";

ghPages.publish("dist", function (err) {
  err ? console.error(err) : console.log("synced to github pages");
});
