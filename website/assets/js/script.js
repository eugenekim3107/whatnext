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
    featurescontent = document.getElementById("features");
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

        // Clear previous iframe in videoContainer, if any
        videoContainer.innerHTML = '';

        // Create a new iframe for video
        var iframe = document.createElement('iframe');
        iframe.className = 'video-iframe';
        iframe.setAttribute('width', '300');
        iframe.setAttribute('height', '600');
        iframe.setAttribute('frameborder', '0');
        iframe.setAttribute('allow', 'accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture');
        iframe.setAttribute('allowfullscreen', true);

        // Update the video-container based on the clicked link
        switch (contentId) {
            case 'Map_demo':
                iframe.setAttribute('src', 'https://youtube.com/embed/fgXpfscnhNY?autoplay=1');
                iframe.setAttribute('allow', 'accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture');
                iframe.setAttribute('frameborder', '0');
                iframe.setAttribute('allowfullscreen', true);
                break;
            case 'Search_demo':
                iframe.setAttribute('src', 'https://www.youtube.com/embed/-opEzttdqPw?autoplay=1');
                iframe.setAttribute('allow', 'accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture');
                iframe.setAttribute('frameborder', '0');
                iframe.setAttribute('allowfullscreen', true);
                break;
            case 'Profile_demo':
                iframe.setAttribute('src', 'https://www.youtube.com/embed/MmkipIj1EZE?autoplay=1');
                iframe.setAttribute('allow', 'accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture');
                iframe.setAttribute('frameborder', '0');
                iframe.setAttribute('allowfullscreen', true);
                break;
            case 'More_demo':
                iframe.setAttribute('src', 'https://www.youtube.com/embed/S5-cXhSLH08?autoplay=1');
                iframe.setAttribute('allow', 'accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture');
                iframe.setAttribute('frameborder', '0');
                iframe.setAttribute('allowfullscreen', true);
                break;
            case 'Explore_demo':
                iframe.setAttribute('src', 'https://www.youtube.com/embed/-E5j0AFWrjY?autoplay=1');
                iframe.setAttribute('allow', 'accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture');
                iframe.setAttribute('frameborder', '0');
                iframe.setAttribute('allowfullscreen', true);
                break;
            default:
                iframe.setAttribute('src', 'https://www.youtube.com/embed/IA7WOT-locw?autoplay=1');
                iframe.setAttribute('allow', 'accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture');
                iframe.setAttribute('frameborder', '0');
                iframe.setAttribute('allowfullscreen', true);
                break;
        }

        // Append the new iframe to videoContainer
        videoContainer.appendChild(iframe);
    });
});

document.querySelectorAll('.sidebar a').forEach(link => {
    link.addEventListener('click', function(e) {
        e.preventDefault();
        if (!this.classList.contains('clicked')) {
            document.querySelectorAll('.sidebar a').forEach(item => {
                item.classList.remove('clicked');
                let existingArrow = item.querySelector('.arrow');
                if (existingArrow) {
                    existingArrow.remove();
                }
            });
            this.classList.add('clicked');

            let arrow = this.querySelector('.arrow');
            if (!arrow) {
                arrow = document.createElement('span');
                arrow.className = 'arrow';
                arrow.innerHTML = '←';
                this.insertBefore(arrow, this.firstChild);
            }
        }
    });
});


document.addEventListener('DOMContentLoaded', (event) => {
    const overviewLink = document.querySelector('.sidebar a[href="#Overview_demo"]');
    if (overviewLink) {
        overviewLink.click();
    }
});
