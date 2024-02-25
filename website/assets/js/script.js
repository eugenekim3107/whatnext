// Existing smooth scroll functionality
document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener('click', function (e) {
        e.preventDefault(); // Prevent the default anchor behavior

        const targetId = this.getAttribute('href'); // Get the anchor target
        const targetElement = document.querySelector(targetId); // Find the target element

        if (targetElement) {
            targetElement.scrollIntoView({ // Scroll to the target element
                behavior: 'smooth' // Ensure the scrolling is smooth
            });
        }
    });
});

// Add the carousel functionality here
let slideIndex = 0;
showSlides();

function showSlides() {
    let i;
    let slides = document.getElementsByClassName("carousel-slide");
    for (i = 0; i < slides.length; i++) {
        slides[i].style.opacity = "0"; 
    }
    slideIndex++;
    if (slideIndex > slides.length) {slideIndex = 1}    
    slides[slideIndex-1].style.opacity = "1";  
    setTimeout(showSlides, 4000); // Change image every 4 seconds
}

function openTab(evt, tabName) {
    var i, tabcontent, tablinks;

    // Get all elements with class="tabcontent" and hide them
    tabcontent = document.getElementsByClassName("tabcontent");
    for (i = 0; i < tabcontent.length; i++) {
        tabcontent[i].style.display = "none";
        tabcontent[i].className = tabcontent[i].className.replace(" active", "");
    }

    // Get all elements with class="page-tabs-header" and remove the class "active"
    tablinks = document.getElementsByClassName("page-tabs-header");
    tabletterlinks = document.getElementsByClassName("page-tabs-header-container")
    for (i = 0; i < tablinks.length; i++) {
        tablinks[i].className = tablinks[i].className.replace(" active", "");
        tabletterlinks[i].className = tabletterlinks[i].className.replace(" active", "");
    }

    // Show the current tab, and add an "active" class to the link that opened the tab and to the tab content
    document.getElementById(tabName).style.display = "flex";
    document.getElementById(tabName).className += " active";
    document.getElementById(tabName+"-letters").className += " active";
    evt.currentTarget.className += " active";
}

// Assuming your sidebar links have unique IDs or classes
document.querySelectorAll('.sidebar a').forEach(link => {
    link.addEventListener('click', function(e) {
        e.preventDefault(); // Prevent default anchor behavior

        const contentId = this.getAttribute('href').substring(1); // Get the content identifier from the href
        const videoContainer = document.querySelector('.video-container');

        // Update the video-container based on the clicked link
        switch (contentId) {
            case 'Map_demo':
                videoContainer.textContent = 'Map content goes here';
                break;
            case 'Search_demo':
                videoContainer.textContent = 'Search content goes here';
                break;
            case 'Profile_demo':
                videoContainer.textContent = 'Profile content goes here';
                break;
            case 'More_demo':
                videoContainer.textContent = 'More content goes here';
                break;
            case 'Explore_demo':
                videoContainer.textContent = 'Explore content goes here';
                break;
            default:
                videoContainer.textContent = 'Select an option';
        }
    });
});
document.querySelectorAll('.sidebar a').forEach(link => {
    link.addEventListener('click', function(e) {
        e.preventDefault(); // Prevent the default link behavior

        // Remove existing arrows if any
        document.querySelectorAll('.sidebar a .arrow').forEach(arrow => {
            arrow.remove();
        });

        // Create a new arrow element pointing left
        let arrow = document.createElement('span');
        arrow.className = 'arrow';
        arrow.innerHTML = '←';

        this.appendChild(arrow);

        // Your existing code to change the video-container text
    });
});

