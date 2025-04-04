const LoadUserList = {
  mounted() {
    console.log("LoadUserList hook mounted");
    this.pushEvent("load-user-list", {});
    
    this.handleSearch();
  },
  
  updated() {
    console.log("LoadUserList hook updated");
    this.handleSearch();
  },
  
  handleSearch() {
    const searchInput = document.getElementById("user-search");
    if (searchInput) {
      // Remove any existing event listener to prevent duplicates
      const newSearchInput = searchInput.cloneNode(true);
      searchInput.parentNode.replaceChild(newSearchInput, searchInput);
      
      newSearchInput.addEventListener("input", (e) => {
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
