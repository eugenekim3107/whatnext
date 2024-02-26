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
                videoContainer.textContent = 'Map Features';
                var iframe = document.createElement('iframe');
                iframe.setAttribute('width', '300');
                iframe.setAttribute('height', '600');
                iframe.setAttribute('src', 'https://youtube.com/embed/fgXpfscnhNY?autoplay=1');
                iframe.setAttribute('frameborder', '0');
                iframe.setAttribute('allow', 'accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture');
                iframe.setAttribute('allowfullscreen', true);
                videoContainer.appendChild(iframe);
                break;
            case 'Search_demo':
                videoContainer.textContent = 'Search Feature';
                var iframe = document.createElement('iframe');
                iframe.setAttribute('width', '300');
                iframe.setAttribute('height', '600');
                iframe.setAttribute('src', 'https://www.youtube.com/embed/-opEzttdqPw?autoplay=1');
                iframe.setAttribute('frameborder', '0');
                iframe.setAttribute('allow', 'accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture');
                iframe.setAttribute('allowfullscreen', true);
                videoContainer.appendChild(iframe);
                break;
            case 'Profile_demo':
                videoContainer.textContent = 'Profile Feature';
                var iframe = document.createElement('iframe');
                iframe.setAttribute('width', '300');
                iframe.setAttribute('height', '600');
                iframe.setAttribute('src', 'https://www.youtube.com/embed/MmkipIj1EZE?autoplay=1');
                iframe.setAttribute('frameborder', '0');
                iframe.setAttribute('allow', 'accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture');
                iframe.setAttribute('allowfullscreen', true);
                videoContainer.appendChild(iframe);
                break;
            case 'More_demo':
                videoContainer.textContent = 'More';
                var iframe = document.createElement('iframe');
                iframe.setAttribute('width', '300');
                iframe.setAttribute('height', '600');
                iframe.setAttribute('src', 'https://www.youtube.com/embed/S5-cXhSLH08?autoplay=1');
                iframe.setAttribute('frameborder', '0');
                iframe.setAttribute('allow', 'accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture');
                iframe.setAttribute('allowfullscreen', true);
                videoContainer.appendChild(iframe);
                break;
            case 'Explore_demo':
                videoContainer.textContent = 'Explore Feature';
                var iframe = document.createElement('iframe');
                iframe.setAttribute('width', '300');
                iframe.setAttribute('height', '600');
                iframe.setAttribute('src', 'https://www.youtube.com/embed/-E5j0AFWrjY?autoplay=1');
                iframe.setAttribute('frameborder', '0');
                iframe.setAttribute('allow', 'accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture');
                iframe.setAttribute('allowfullscreen', true);
                videoContainer.appendChild(iframe);
                break;
            default:
                videoContainer.textContent = 'Project Overview';
                var iframe = document.createElement('iframe');
                iframe.setAttribute('width', '300');
                iframe.setAttribute('height', '600');
                iframe.setAttribute('src', 'https://www.youtube.com/embed/IA7WOT-locw?autoplay=1');
                iframe.setAttribute('frameborder', '0');
                iframe.setAttribute('allow', 'accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture');
                iframe.setAttribute('allowfullscreen', true);
                videoContainer.appendChild(iframe);
                break;
        }
    });
});
document.querySelectorAll('.sidebar a').forEach(link => {
    link.addEventListener('click', function(e) {

        e.preventDefault(); // Prevent default action
        

        // Remove .clicked class and arrow from all items except the clicked one
        document.querySelectorAll('.sidebar a').forEach(item => {
            if (item !== this) {
                item.classList.remove('clicked');
                let existingArrow = item.querySelector('.arrow');
                if (existingArrow) {
                    existingArrow.remove();
                }
            }
        });

        // Toggle .clicked class on this item
        this.classList.toggle('clicked');

        // Manage the arrow for the clicked item
        let arrow = this.querySelector('.arrow');
        if (!arrow) {
            // If no arrow exists, create and append it
            arrow = document.createElement('span');
            arrow.className = 'arrow';
            arrow.innerHTML = '←'; // Left-pointing arrow
            this.insertBefore(arrow, this.firstChild);
        } else {
            // If arrow exists, remove it to simulate a toggle
            arrow.remove();
        }

        // Adjust video-container text or other actions here
    });
})

document.addEventListener('DOMContentLoaded', (event) => {
    const overviewLink = document.querySelector('.sidebar a[href="#Overview_demo"]'); // Adjust the selector as needed
    if (overviewLink) {
        overviewLink.click();
    }
});
