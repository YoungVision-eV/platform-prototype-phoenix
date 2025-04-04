const LoadUserList = {
  mounted() {
    this.pushEvent("load-user-list", {});
    
    const searchInput = document.getElementById("user-search");
    if (searchInput) {
      searchInput.addEventListener("input", (e) => {
        const searchTerm = e.target.value.toLowerCase();
        const userItems = document.querySelectorAll("#user-list a");
        
        userItems.forEach(item => {
          const userName = item.querySelector("div").textContent.toLowerCase();
          const userEmail = item.querySelector("div:nth-child(2)").textContent.toLowerCase();
          
          if (userName.includes(searchTerm) || userEmail.includes(searchTerm)) {
            item.style.display = "block";
          } else {
            item.style.display = "none";
          }
        });
      });
    }
  }
};

export default LoadUserList;
