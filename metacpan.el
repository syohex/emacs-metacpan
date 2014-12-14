;;; metacpan.el --- metacpan API

;; Copyright (C) 2014 by Syohei YOSHIDA

;; Author: Syohei YOSHIDA <syohex@gmail.com>
;; URL: https://github.com/syohex/
;; Version: 0.01

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;;; Code:

(require 'url)
(require 'json)
(require 'cl-lib)

(defconst metacpan--search-base-uri
  "https://api.metacpan.org/v0/search/autocomplete")

(defsubst metacpan--format-search-uri (query)
  (concat metacpan--search-base-uri "/?q=" query))

(defun metacpan--parse-search-response (response)
  (cl-loop for candidate across (assoc-default 'hits (assoc-default 'hits response))
           for fields = (assoc-default 'fields candidate)
           collect
           (list :distribution (assoc-default 'distribution fields)
                 :release (assoc-default 'release fields)
                 :author (assoc-default 'author fields)
                 :score (assoc-default '_score candidate))))

(defun metacpan--search-get (query)
  (let* ((url-request-method "GET")
         (buf (url-retrieve-synchronously (metacpan--format-search-uri query) t)))
    (with-current-buffer buf
      (goto-char (point-min))
      (when (re-search-forward "\n\n" nil t)
        (let ((response (json-read-from-string (buffer-substring-no-properties
                                                (point) (point-max)))))
          (metacpan--parse-search-response response))))))

;;;###autoload
(defun metacpan-search (query)
  (interactive
   (list (read-string "Query: ")))
  (metacpan--search-get query))

(provide 'metacpan)

;;; metacpan.el ends here
