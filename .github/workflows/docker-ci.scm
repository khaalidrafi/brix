;; -*- mode: scheme; -*-
;; This is an operating system configuration template for a "Docker image"
;; setup, so it has barely any services at all.

(use-modules (gnu)
             (srfi srfi-1))

(use-service-modules shepherd base)

(define %profile "/run/current-system/profile")

(operating-system
  (host-name "brix-os")
  (timezone "Asia/Dhaka")
  (locale "en_GB.utf8")

  ;; This is where user accounts are specified.  The "root" account is
  ;; implicit, and is initially created with the empty password.
  (users (cons (user-account
                 (name "brix")
                 (comment "Build your bricks!")
                 (uid 1000)
                 (group "users")
                 (supplementary-groups '("wheel"
                                         "audio" "video")))
               %base-user-accounts))

  ;; Globally-installed packages.
  (packages %base-packages)

  ;; Because the system will run in a Docker container, we may omit many
  ;; things that would normally be required in an operating system
  ;; configuration file.  These things include:
  ;;
  ;;   * bootloader
  ;;   * file-systems
  ;;   * services such as mingetty, udevd, slim, networking, dhcp
  ;;
  ;; Either these things are simply not required, or Docker provides
  ;; similar services for us.

  ;; This will be ignored.
  (bootloader (bootloader-configuration
                (bootloader grub-bootloader)
                (targets '("does-not-matter"))))
  ;; This will be ignored, too.
  (file-systems (list (file-system
                        (device "does-not-matter")
                        (mount-point "/")
                        (type "does-not-matter"))))

  (services
   (append
    (let
        ((%ignored-services (list login-service-type
                                  virtual-terminal-service-type
                                  console-font-service-type
                                  agetty-service-type
                                  mingetty-service-type))

         (initial-symlinks
          '(("/bin/bash" ,(string-append %profile "/bin/bash"))
            ("/etc/profile" "/run/current-system/etc/profile")))

         (fhs-mappings (map (lambda (pair)
                              (list (car pair)
                                    (string-append %profile
                                                   (cadr pair))))
                            '(("/lib" "/lib")
                              ("/sbin" "/sbin")
                              ("/usr/include" "/include")
                              ("/usr/libexec" "/libexec")
                              ("/usr/share" "/share"))))
         (fhs-symlinks
          ;; Matches fhs-symlinks in setup-fhs:
          ;; /usr/lib -> /lib, /lib64 -> /lib, /usr/bin -> /bin, /usr/sbin -> /sbin
          '(("/usr/lib" "/lib")
            ("/lib64" "/lib")
            ("/usr/sbin" "/sbin")
            ("/usr/bin" "/bin"))))

      (modify-services

          (remove (lambda (service)
                    (member (service-kind service)
                            %ignored-services))
                  %base-services)

        (guix-service-type config =>
                           (guix-configuration
                             (inherit config)
                             (generate-substitute-key? #f)))

        (special-files-service-type files =>
                                    (append
                                     initial-symlinks
                                     fhs-mappings
                                     fhs-symlinks
                                     ))

        )
      )

    ))
  )
